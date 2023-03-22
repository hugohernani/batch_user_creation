class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :password, presence: true, length: { in: 10..20 },
                       contains_lowercase: true, contains_uppercase: true,
                       contains_digit: true, no_repeating_character: true
end
