FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    profile_text { Faker::Lorem.paragraph }

    trait :admin do
      admin { true }
    end
  end
end
