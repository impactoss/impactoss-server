FactoryGirl.define do
  factory :measure do
    title 'MyString'
    description 'MyText'
    target_date 'MyText'
    recommendations { [create(:recommendation)] }
    categories { [create(:category)] }

    trait :without_recommendation do
      recommendations { [] }
    end

    trait :without_category do
      categories { [] }
    end
  end
end
