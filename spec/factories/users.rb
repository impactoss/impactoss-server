# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { "password" }
    password_confirmation { password }
  end

  trait :admin do
    roles { [Role.find_by(name: "admin")] }
  end

  trait :manager do
    roles { [Role.find_by(name: "manager")] }
  end

  trait :contributor do
    roles { [Role.find_by(name: "contributor")] }
  end
end
