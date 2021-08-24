FactoryBot.define do
  factory :event do
    name { ['Ruby Conf', 'CCXP', 'Anime Friends'].sample }
    local { %w[Online SP Cotia].sample }
    description { 'Melhor evento da história' }
    owner { ['John Doe', 'Jane Doe', 'Henrique Morato'].sample }
    start_date { 2.days.from_now }
    end_date { 5.days.from_now }
  end
end
