FactoryGirl.define do
  factory :bookmark do
    association :user

    title Faker::Lorem.sentence
    view {{lorem: Faker::Lorem.sentence}}
  end
end
