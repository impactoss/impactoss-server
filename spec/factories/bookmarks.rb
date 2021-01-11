FactoryGirl.define do
  factory :bookmark do
    association :user

    bookmark_type 1
    title Faker::Lorem.sentence
    view {{lorem: Faker::Lorem.sentence}}
  end
end
