# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { password }
  end

  trait :admin do
    roles { [create(:role, :admin)] }
  end

  trait :manager do
    roles { [create(:role, :manager)] }
  end

  trait :reporter do
    roles { [create(:role, :reporter)] }
  end
end
