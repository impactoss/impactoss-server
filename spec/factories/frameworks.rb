FactoryGirl.define do
  factory :framework do
    title { Faker::Creature::Cat.registry }
  end
end
