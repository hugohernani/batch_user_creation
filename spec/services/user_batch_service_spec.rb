require 'rails_helper'
require 'csv'

describe UserBatchService do
  subject(:service) { described_class.new(file_path) }

  describe 'call' do
    let(:turbo_stream) { class_double(Turbo::StreamsChannel, broadcast_prepend_to: nil) }

    before do
      stub_const('Turbo::StreamsChannel', turbo_stream)
    end

    context 'when all data are valid' do
      let(:file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'valid.csv') }

      let(:csv_users) do
        CSV.read(file_path, headers: true).pluck('name')
      end

      it 'persists all incoming users into database' do
        service.call

        persisted_users_count = User.where(name: csv_users).count
        expect(persisted_users_count).to eq(csv_users.size)
      end

      it 'delegates stream response for each csv user' do # rubocop:disable RSpec/ExampleLength
        service.call

        turbo_broadcast_expectations = {
          target: 'user_listing',
          partial: 'batch/users/valid_response',
          locals: { user: be_a(Users::ValidResponsePresenter) }
        }
        expect(turbo_stream).to have_received(:broadcast_prepend_to)
          .with('user_listing', **turbo_broadcast_expectations)
          .exactly(csv_users.size).times
      end
    end

    context 'when there are invalid data' do
      let(:file_path) do
        Tempfile.new('users-csv').tap do |temp|
          temp << csv_data
          temp.rewind
        end.path
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
        service.call

        valid_csv_users = ['Valid User 1', 'Valid User 2']
        persisted_users_count = User.where(name: valid_csv_users).count
        expect(persisted_users_count).to eq(valid_csv_users.size)
      end

      it 'does not persist the invalid ones into database', :aggregate_failures do
        service.call

        invalid_csv_users = ['Invalid User 1', 'Invalid User 2']
        filtered_invalid_users_count = User.where(name: invalid_csv_users).count

        expect(User.count).to be > 0
        expect(filtered_invalid_users_count).to eq 0
      end

      it 'delegates a stream response for each csv user', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        service.call

        turbo_broadcast_expectations = { target: 'user_listing' }
        valid_expectations = {
          partial: 'batch/users/valid_response',
          locals: { user: be_a(Users::ValidResponsePresenter) }
        }
        invalid_expectations = {
          partial: 'batch/users/invalid_response',
          locals: { user: be_a(Users::InvalidResponsePresenter) }
        }

        expect(turbo_stream).to have_received(:broadcast_prepend_to)
          .with('user_listing', **turbo_broadcast_expectations.merge(valid_expectations))
          .exactly(2).times
        expect(turbo_stream).to have_received(:broadcast_prepend_to)
          .with('user_listing', **turbo_broadcast_expectations.merge(invalid_expectations))
          .exactly(2).times
      end
    end
  end
end
