FactoryGirl.define do
  factory :measure_category do
    association :category
    association :measure
  end
end
