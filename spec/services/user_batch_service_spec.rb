require 'rails_helper'
require 'csv'

describe UserBatchService do
  before { described_class.call(file_path) }

  describe '.call' do
    context 'when all data are valid' do
      let(:file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'valid.csv') }

      let(:csv_users) do
        CSV.read(file_path, headers: true).pluck('name')
      end

      it 'persists all incoming users into database' do
        persisted_users_count = User.where(name: csv_users).count

        expect(persisted_users_count).to eq(csv_users.size)
      end

      it 'delegates event notification for each csv user' do # rubocop:disable RSpec/ExampleLength
        # TODO: Change 'anything()' to something such as 'BatchUser::Response'
        turbo_broadcast_expectations = {
          target: :user_listing,
          partial: 'batch/users/response',
          locals: { user: anything, success: true }
        }
        expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
          .with('user_listing', **turbo_broadcast_expectations)
          .exactly(csv_users.size).times
      end
    end

    context 'when there are invalid data' do
      let(:file_path) do
        Tempfile.create { |temp| temp << csv_data }.path
      end
      let(:csv_data) do
        <<~CSV
          name,password
          Valid User 1, a1C2e3G4h5
          Invalid User 1, abc
          Valid User 2, 5h4G3e2C1#{' '}
          Invalid User 2, acefghjlnp
        CSV
      end
      let(:csv_users) { CSV.parse(csv_data) }

      it 'persists the valid ones into database' do
        valid_csv_users = ['Valid User 1', 'Valid User 2']
        persisted_users_count = User.where(name: valid_csv_users).count

        expect(persisted_users_count).to eq(valid_csv_users.size)
      end

      it 'does not persist the invalid ones into database', :aggregate_failures do
        invalid_csv_users = ['Invalid User 1', 'Invalid User 2']
        filtered_invalid_users_count = User.where(name: invalid_csv_users).count

        expect(User.count).to be > 0
        expect(filtered_invalid_users_count).to eq 0
      end

      it 'delegates event notification for each csv user' do # rubocop:disable RSpec/ExampleLength
        # TODO: Change 'anything()' to something such as 'BatchUser::Response'
        turbo_broadcast_expectations = {
          target: :user_listing,
          partial: 'batch/users/response',
          locals: { user: anything, success: be_in([true, false]) }
        }
        expect(Turbo::StreamsChannel).to have_received(:broadcast_prepend_to)
          .with('user_listing', **turbo_broadcast_expectations)
          .exactly(csv_users.size).times
      end
    end
  end
end
