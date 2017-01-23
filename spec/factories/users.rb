# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { 'password' }
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
end
