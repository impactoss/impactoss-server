FactoryGirl.define do
  factory :sdgtarget_measure do
    association :sdgtarget
    association :measure
  end
end
