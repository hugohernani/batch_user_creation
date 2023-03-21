require 'rails_helper'

describe Users::ValidResponsePresenter do
  subject(:presenter) { described_class.new(user) }

  let(:user) { create(:user) }

  describe '#partial_path' do
    it { expect(presenter.partial_path).to eq('batch/users/valid_response') }
  end
end
