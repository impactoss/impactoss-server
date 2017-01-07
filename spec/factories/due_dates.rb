FactoryGirl.define do
  factory :due_date do
    indicator { create(:indicator) }
    due_date '2017-01-06'
  end
end
