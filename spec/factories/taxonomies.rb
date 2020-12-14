FactoryGirl.define do
  factory :taxonomy do
    title 'MyString'
    tags_measures false
    allow_multiple false

    association :framework, strategy: :null

    trait :parent_taxonomy do
      title:'parent'
    end

    trait :sub_taxonomy do
      title:'parent'
      association :taxonomy, :parent_taxonomy
    end
  end
end
