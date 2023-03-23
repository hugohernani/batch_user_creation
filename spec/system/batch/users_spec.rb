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
          users = peek_users(valid_csv_file_path, 1)

          expect(page).to have_content(users[0])
        end
      end
    end

    context 'when there are invalid users' do
      let(:invalid_csv_file_path) { Rails.root.join('spec', 'fixtures', 'batch', 'users', 'invalid.csv') }

      it 'creates each user in it', :aggregate_failures do
        visit root_path

        attach_file('file_handler[csv]', invalid_csv_file_path)
        submit_form

        within '#user_responses' do
          user = peek_users(invalid_csv_file_path, 1)[0]

          first_user_response = page.find_by_id('1_response')
          expect(first_user_response).to have_content(user)
          expect(first_user_response).to have_css('.errors', text: 'should have at least one lowercase')
          expect(first_user_response).to have_css('.errors', text: 'should have at least one digit')
          expect(first_user_response).to have_css('.errors', text: 'should not contain 3 or more characters in a row')
          expect(first_user_response).to have_css('.errors', text: 'too short')
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
  end
end
