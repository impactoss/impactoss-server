FactoryGirl.define do
  factory :role do
    name { Faker::Lorem.word }
    friendly_name { Faker::Lorem.sentence }

    trait :admin do
      name { 'admin' }
    end

    trait :manager do
      name { 'manager' }
    end

    trait :reporter do
      name { 'reporter' }
    end
  end
end
