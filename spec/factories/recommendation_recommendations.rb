FactoryGirl.define do
    factory :recommendation_recommendation do
      association :recommendation
      association :other_recommendation, factory: :recommendation
    end
  end