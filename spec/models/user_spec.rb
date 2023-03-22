require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:password) }

    it { is_expected.to have_secure_password }

    describe 'password validations' do
      before { user.valid? }

      context 'when its size is less than minimum constraint' do
        let(:user) { build(:user, password: 'aA1D$') }

        it 'adds size validation error' do
          expect(user.errors.full_messages).to include(Regexp.new('too short'))
        end
      end

      context 'when its size is greater than maximum constraint' do
        let(:user) { build(:user, password: 'aA1D$7gwWt#d14ghaSf8ad@#*') }

        it 'adds size validation error' do
          expect(user.errors.full_messages).to include(Regexp.new('too long'))
        end
      end

      context 'when it does not contain at least one lowercase character' do
        let(:user) { build(:user, password: 'A%C$ESYQEGD') }

        it 'adds lowercase character error' do
          lowercase_character_error = 'Password should have at least one lowercase character'
          expect(user.errors.full_messages).to include(lowercase_character_error)
        end
      end

      context 'when it does not contain at least one uppercase character' do
        let(:user) { build(:user, password: 'a%c$es23yqegd') }

        it 'adds uppercase character error' do
          uppercase_character_error = 'Password should have at least one uppercase character'
          expect(user.errors.full_messages).to include(uppercase_character_error)
        end
      end

      context 'when it does not contain at least one digit character' do
        let(:user) { build(:user, password: 'A%C$esYQEGD') }

        it 'adds digit character error' do
          digit_character_error = 'Password should have at least one digit character'
          expect(user.errors.full_messages).to include(digit_character_error)
        end
      end

      context 'when it contains at least 3 repeating characters in a row' do
        let(:user) { build(:user, password: 'aaaB$G24lk51') }

        it 'adds repeating character error' do
          repeating_character_error = 'Password should not contain 3 or more characters in a row'
          expect(user.errors.full_messages).to include(repeating_character_error)
        end
      end
    end
  end
end
