FactoryBot.define do
  factory :sdgtarget_category do
    association :sdgtarget
    association :category
  end
end
