require 'rails_helper'

describe Users::ValidResponsePresenter do
  subject(:presenter) { described_class.new(user, row_number) }

  let(:row_number) { 5 }
  let(:user) { create(:user) }

  describe '#id' do
    it { expect(presenter.id).to eq row_number }
  end

  describe '#name' do
    it { expect(presenter.name).to eq user.name }
  end

  describe '#partial_path' do
    it { expect(presenter.partial_path).to eq('batch/users/valid_response') }
  end
end
