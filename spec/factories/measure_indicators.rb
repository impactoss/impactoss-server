FactoryBot.define do
  factory :measure_indicator do
    association :measure
    association :indicator
  end
end
