FactoryBot.define do
  factory :category do
    title { Faker::Ancient.hero }
    short_title { Faker::Ancient.primordial }
    description { Faker::Movies::StarWars.quote }
    url { Faker::Internet.url }
    association :taxonomy

    trait :is_archive do
      is_archive { true }
    end

    trait :parent_category do
      title { "parent" }
    end

    trait :sub_category do
      title { "sub" }
    end

    trait :has_date do
      date { Date.today }
    end
  end
end
