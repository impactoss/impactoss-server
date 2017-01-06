# frozen_string_literal: true
FactoryGirl.define do
  factory :indicator do
    title 'MyString'
    description 'MyText'
    measures { [create(:measure)] }

    trait :without_measure do
      measures { [] }
    end
  end
end
