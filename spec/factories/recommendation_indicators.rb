FactoryGirl.define do
  factory :recommendation_indicator do
    association :recommendation
    association :indicator
  end
end
