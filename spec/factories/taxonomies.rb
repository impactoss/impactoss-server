FactoryGirl.define do
  factory :taxonomy do
    title 'MyString'
    tags_measures false
    allow_multiple false
    association :framework
  end
end
