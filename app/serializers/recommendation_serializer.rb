class RecommendationSerializer
  include FastVersionedSerializer

  attributes :title, :accepted, :response, :draft, :reference, :description

  set_type :recommendations
end
