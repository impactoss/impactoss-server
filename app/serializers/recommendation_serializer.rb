class RecommendationSerializer
  include FastApplicationSerializer

  attributes :title, :accepted, :response, :draft, :reference

  set_type :recommendations
end
