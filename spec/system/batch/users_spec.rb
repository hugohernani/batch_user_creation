require 'csv'
require 'rails_helper'

RSpec.describe 'Batch::Users', inline_sidekiq: true do
  describe 'uploading a batch users csv file' do
    context 'when all users are valid' do
      let(:valid_csv_file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'valid.csv') }

      it 'creates each user in it' do
        visit root_path

        attach_file('file_handler[csv]', valid_csv_file_path)
        submit_form

        within '#user_responses' do
          users = peek_users(valid_csv_file_path, 3)

          expect(page).to have_content(users[0])
          expect(page).to have_content(users[1])
          expect(page).to have_content(users[2])
        end
      end
    end

    context 'when there are invalid users', headless: false do
      let(:invalid_csv_file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'invalid.csv') }

      it 'creates each user in it' do
        visit root_path

        attach_file('file_handler[csv]', invalid_csv_file_path)
        submit_form

        within '#user_responses' do
          users = peek_users(invalid_csv_file_path, 3)

          apply_expectation_for_invalid_user(users[0], 1)
          apply_expectation_for_invalid_user(users[1], 2)
          apply_expectation_for_invalid_user(users[2], 3)
        end
      end
    end

    def submit_form
      find('input[name="commit"]').click
    end

    def peek_users(file_path, quantity)
      csv = CSV.foreach(file_path, headers: true).take(quantity)
      csv.pluck('name')
    end

    def apply_expectation_for_invalid_user(user, mocked_row_number)
      expect(page).to have_content("(#{mocked_row_number} - INVALID)")
      expect(page).to have_content(user)
    end
  end
end
