# frozen_string_literal: true

FactoryBot.define do
  factory :indicator do
    title { Faker::Lorem.sentence }
    description { Faker::Hipster.sentence }
    sequence(:reference) { Faker::Creature::Dog.breed + _1.to_s }

    trait :is_archive do
      is_archive { true }
    end

    trait :without_measure do
      measures { [] }
    end

    trait :with_repeat do
      repeat { true }
      end_date { Date.today + 1.year }
      start_date { Date.today }
      frequency_months { 1 }
    end

    trait :without_repeat do
      repeat { false }
      start_date { Date.today }
    end

    trait :with_12_due_dates do
      repeat { true }
      end_date { Date.today + 1.year - 15.days }
      start_date { Date.today }
      frequency_months { 1 }
    end

    trait :with_manager do
      manager { create(:user) }
    end
  end
end
