FactoryBot.define do
  factory :event do
    name { ['Ruby Conf', 'CCXP', 'Anime Friends'].sample }
    local { %w[Online SP Cotia].sample }
    description { 'Melhor evento da história' }
    owner_id { create(:user).id }
    start_date { 2.days.from_now }
    end_date { 5.days.from_now }
  end
end
