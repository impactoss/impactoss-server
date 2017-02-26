# frozen_string_literal: true
FactoryGirl.define do
  factory :recommendation do
    title { Faker::Superhero.name }
    number 1

    trait :without_category do
      categories { [] }
    end
  end
end
