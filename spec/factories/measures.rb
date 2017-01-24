FactoryGirl.define do
  factory :measure do
    title 'MyString'
    description 'MyText'
    target_date 'MyText'

    trait :without_recommendation do
      recommendations { [] }
    end

    trait :without_category do
      categories { [] }
    end
  end
end
