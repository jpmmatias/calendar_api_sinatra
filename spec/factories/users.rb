require 'faker'
FactoryBot.define do
  factory :user, class: User do
    name { Faker::Name.first_name }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    password { 'senha@123' }
  end
end
