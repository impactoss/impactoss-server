class MeasureSerializer
  include FastVersionedSerializer

  attributes :title, :description, :reference, :target_date, :draft, :outcome, :indicator_summary, :target_date_comment, :relationship_updated_at, :relationship_updated_by_id

  set_type :measures
end
