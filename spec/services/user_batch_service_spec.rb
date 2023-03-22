require 'rails_helper'
require 'csv'

describe UserBatchService do
  subject(:service) { described_class.new(file_handler) }

  let(:file_handler) do
    create(:file_handler).tap do |handler|
      handler.csv.attach(io: File.open(file_path), filename: 'users.csv', content_type: 'application/pdf')
    end
  end

  describe 'call' do
    let(:turbo_stream) do
      class_double(Turbo::StreamsChannel, broadcast_append_to: nil, broadcast_update_to: nil)
    end

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

      it "delegates 'update' stream response for first csv user" do
        service.call

        expect(turbo_stream).to have_received(:broadcast_update_to)
          .with('users_batch', **turbo_broadcast_expectations('valid'))
          .once
      end

      it 'delegates stream response for each csv user' do
        service.call

        expect(turbo_stream).to have_received(:broadcast_append_to)
          .with('users_batch', **turbo_broadcast_expectations('valid'))
          .exactly(csv_users.size - 1).times
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

        expect(turbo_stream).to have_received(:broadcast_update_to)
          .with('users_batch', **turbo_broadcast_expectations('valid'))
          .once
        expect(turbo_stream).to have_received(:broadcast_append_to)
          .with('users_batch', **turbo_broadcast_expectations('invalid'))
          .exactly(2).times
        expect(turbo_stream).to have_received(:broadcast_append_to)
          .with('users_batch', **turbo_broadcast_expectations('invalid'))
          .exactly(2).times
      end
    end

    def turbo_broadcast_expectations(partial_type)
      {
        target: 'user_responses',
        partial: "batch/users/#{partial_type}_response",
        locals: { user: be_a(Users::BaseResponsePresenter) }
      }
    end
  end
end
