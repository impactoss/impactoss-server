class MeasureSerializer
  include FastVersionedSerializer

  attributes :title, :description, :reference, :target_date, :draft, :outcome, :indicator_summary, :target_date_comment

  set_type :measures
end
