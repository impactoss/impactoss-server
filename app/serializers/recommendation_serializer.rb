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
    :relationship_updated_by_id
  )

  set_type :recommendations
end
