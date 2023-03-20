require 'csv'
require 'rails_helper'

RSpec.describe 'Batch::Users' do
  describe 'uploading a batch users csv file' do
    context 'when all users are valid' do
      let(:valid_csv_file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'valid.csv') }

      it 'creates each user in it' do
        visit root_path

        attach_file('file_handler[csv]', valid_csv_file_path)
        submit_form

        within '#users_listing' do
          users = peek_users(valid_csv_file_path, 3)

          expect(page).to have_content(users[0])
          expect(page).to have_content(users[1])
          expect(page).to have_content(users[2])
        end
      end
    end

    context 'when there are invalid users' do
      let(:invalid_csv_file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'invalid.csv') }

      it 'creates each user in it' do
        visit root_path

        attach_file('users_batch', invalid_csv_file_path)

        within '#users_listing' do
          users = peek_users(invalid_csv_file_path, 3)

          # TODO: Filter element to confirm it's invalid
          expect(page).to have_content(users[0])
          expect(page).to have_content(users[1])
          expect(page).to have_content(users[2])
        end
      end
    end

    def peek_users(file_path, quantity)
      csv = CSV.foreach(file_path, headers: true).take(quantity)
      csv.pluck('name')
    end
  end
end
