# frozen_string_literal: true
FactoryGirl.define do
  factory :recommendation do
    title 'MyString'
    number 1
    categories { [create(:category)] }

    trait :without_category do
      categories { [] }
    end
  end
end
