# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { "SecurePassword123!" }
    password_confirmation { "SecurePassword123!" }
    password_changed_at { Time.current }
    confirmed_at { Time.current }  # Auto-confirm for tests
  end

  trait :admin do
    roles { [create(:role, :admin)] }
  end

  trait :manager do
    roles { [create(:role, :manager)] }
  end

  trait :contributor do
    roles { [create(:role, :contributor)] }
  end
end
