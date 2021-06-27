FactoryGirl.define do
    factory :framework_framework do
      association :framework
      association :other_framework, factory: :framework
    end
  end