FactoryGirl.define do
  factory :category do
    title { Faker::Ancient.hero }
    short_title { Faker::Ancient.primordial }
    description { Faker::StarWars.quote }
    url { Faker::Internet.url }
    association :taxonomy
  end
end
