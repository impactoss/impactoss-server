class MeasureSerializer
  include FastVersionedSerializer

  attributes :title,
    :is_current,
    :description,
    :draft,
    :indicator_summary,
    :is_archive,
    :outcome,
    :reference,
    :relationship_updated_at,
    :relationship_updated_by_id,
    :target_date_comment,
    :target_date

  set_type :measures
end
