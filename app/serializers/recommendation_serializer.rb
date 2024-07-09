class RecommendationSerializer
  include FastVersionedSerializer

  attributes :title,
    :accepted,
    :is_current,
    :description,
    :draft,
    :framework_id,
    :is_archive,
    :reference,
    :relationship_updated_at,
    :relationship_updated_by_id,
    :response

  set_type :recommendations
end
