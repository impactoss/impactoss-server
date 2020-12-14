FactoryGirl.define do
    factory :framework_taxonomy do
      association :framework
      association :taxonomy
    end
  end