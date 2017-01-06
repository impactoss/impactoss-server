FactoryGirl.define do
  factory :taxonomy do
    title 'MyString'
    tags_recommendations false
    tags_measures false
    allow_multiple false
  end
end
