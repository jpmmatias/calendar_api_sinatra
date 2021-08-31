require 'faker'
FactoryBot.define do
  factory :user, class: User do
    name { Faker::Name.first_name }
    email { Faker::Internet.safe_email }
    password { 'senha@123' }
  end
end
