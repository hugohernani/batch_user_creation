require 'rails_helper'

describe Users::InvalidResponsePresenter do
  subject(:presenter) { described_class.new(user, row_number) }

  let(:row_number) { 5 }

  describe '#partial_path' do
    let(:user) { create(:user) }

    it { expect(presenter.partial_path).to eq('batch/users/invalid_response') }
  end

  describe '#errors' do
    context 'when name is missing on user' do
      let(:user) { build(:user, name: nil).tap(&:valid?) }

      it 'includes presence message error' do
        name_error = user.errors.messages[:name].join
        error_message = "Name #{name_error}"
        expect(presenter.errors).to include(error_message)
      end
    end
  end
end
