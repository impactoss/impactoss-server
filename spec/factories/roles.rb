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

    trait :contributor do
      name { 'contributor' }
    end
  end
end
