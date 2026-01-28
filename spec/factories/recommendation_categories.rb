FactoryBot.define do
  factory :recommendation_category do
    association :recommendation
    association :category
  end
end
