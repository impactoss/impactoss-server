class RecommendationSerializer
  include FastApplicationSerializer

  attributes :title, :accepted, :response, :draft, :reference, :description

  set_type :recommendations
end
