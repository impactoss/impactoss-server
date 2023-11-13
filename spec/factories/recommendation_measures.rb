FactoryBot.define do
  factory :recommendation_measure do
    association :recommendation
    association :measure
  end
end
