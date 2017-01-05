FactoryGirl.define do
  factory :category do
    title 'MyString'
    short_title 'MyString'
    description 'MyString'
    url 'MyString'
    association :taxonomy
  end
end
