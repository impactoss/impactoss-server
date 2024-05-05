# frozen_string_literal: true

FactoryBot.define do
  factory :recommendation do
    title { Faker::Superhero.name }
    sequence(:reference) { Faker::Creature::Dog.breed + _1.to_s }

    trait :without_category do
      categories { [] }
    end
  end
end
