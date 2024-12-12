FactoryBot.define do
  factory :due_date do
    indicator { create(:indicator) }
    due_date { "2017-01-06" }

    trait :with_manager do
      indicator { create(:indicator, :with_manager) }
    end
  end
end
