class RecommendationSerializer
  include FastVersionedSerializer

  attributes(
    :title,
    :accepted,
    :response,
    :draft,
    :reference,
    :description,
    :framework_id,
    :support_level,
    :relationship_updated_at,
    :relationship_updated_by_id,
    :is_archive
  )

  set_type :recommendations
end
