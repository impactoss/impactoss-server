class IndicatorSerializer
  include FastVersionedSerializer

  attributes :title, :description, :reference, :draft, :manager_id, :frequency_months, :start_date, :repeat, :end_date, :relationship_updated_at, :relationship_updated_by_id

  set_type :indicators
end
