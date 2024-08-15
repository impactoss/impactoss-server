class IndicatorSerializer
  include FastVersionedSerializer

  attributes :title,
    :is_current,
    :description,
    :draft,
    :end_date,
    :frequency_months,
    :is_archive,
    :manager_id,
    :reference,
    :relationship_updated_at,
    :relationship_updated_by_id,
    :repeat,
    :start_date

  set_type :indicators
end
