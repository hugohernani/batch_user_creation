require 'rails_helper'

describe Users::InvalidResponsePresenter do
  subject(:presenter) { described_class.new(user) }

  let(:user) { create(:user) }

  describe '#partial_path' do
    it { expect(presenter.partial_path).to eq('batch/users/invalid_response') }
  end
end
