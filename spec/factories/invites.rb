FactoryBot.define do
  factory :invite do
    sender_id { create(:user).id }
    receiver_id { create(:user).id }
    event
    status { 0 }
  end
end
