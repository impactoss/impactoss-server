FactoryGirl.define do
  factory :role do
    name { Faker::Lorem.word }
    friendly_name { Faker::Lorem.sentence }
  end
end
