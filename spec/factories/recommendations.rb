# frozen_string_literal: true

FactoryBot.define do
  factory :recommendation do
    title { Faker::Superhero.name }
    reference { "1" }

    trait :without_category do
      categories { [] }
    end
  end
end
