FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password do
      Faker::Internet.password(min_length: 10,
                               max_length: 15,
                               mix_case: true,
                               special_characters: true) << rand(10).to_s
    end
  end
end
