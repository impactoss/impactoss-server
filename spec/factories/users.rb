# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { "password" }
    password_confirmation { password }
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

  trait :with_multi_factor_email do
    multi_factor_email_code_enabled { true }
    otp_required_for_login { true }
  end
end
