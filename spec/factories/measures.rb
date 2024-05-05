FactoryBot.define do
  factory :measure do
    title { Faker::Creature::Cat.registry }
    description { Faker::Beer.name }
    sequence(:reference) { Faker::Creature::Dog.breed + _1.to_s }
    target_date { Faker::Date.forward(days: 450) }

    trait :without_recommendation do
      recommendations { [] }
    end

    trait :without_category do
      categories { [] }
    end
  end
end
