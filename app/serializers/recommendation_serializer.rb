class RecommendationSerializer
  include FastVersionedSerializer

  attributes :title, :accepted, :response, :draft, :reference, :description, :framework_id

  set_type :recommendations
end
