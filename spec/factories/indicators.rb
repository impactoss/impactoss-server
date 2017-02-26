# frozen_string_literal: true
FactoryGirl.define do
  factory :indicator do
    title { Faker::ChuckNorris.fact }
    description { Faker::Hipster.sentence }

    trait :without_measure do
      measures { [] }
    end
  end
end
