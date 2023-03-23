class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :password, length: { in: 10..16 },
                       contains_lowercase: true, contains_uppercase: true,
                       contains_digit: true, no_repeating_character: true
end
