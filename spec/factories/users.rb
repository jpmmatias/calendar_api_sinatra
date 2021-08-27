FactoryBot.define do
  factory :user, class: User do
    name { %w[Jose Joana Fabricio].sample }
    email { ['email@gmail.com', 'user@gmail.com', 'misterio@yahoo.com'].sample }
    password { ['senha@123', 'sdvasveger123', 'sdvasveger123'].sample }
  end
end
