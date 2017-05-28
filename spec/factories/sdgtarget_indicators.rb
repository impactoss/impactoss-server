FactoryGirl.define do
  factory :sdgtarget_indicator do
    association :sdgtarget
    association :indicator
  end
end
