class IndicatorSerializer < ApplicationSerializer
  attributes :title, :description, :reference, :draft, :manager_id, :frequency_months, :start_date, :repeat, :end_date
end
