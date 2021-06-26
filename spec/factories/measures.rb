FactoryGirl.define do
  factory :measure do
    title { Faker::Creature::Cat.registry }
    description { Faker::Beer.name }
    target_date { Faker::Date.forward(450) }

    trait :without_recommendation do
      recommendations { [] }
    end

    trait :without_category do
      categories { [] }
    end
  end
end
