class RecommendationRecommendationSerializer
  include FastVersionedSerializer

  attributes :recommendation_id, :other_recommendation_id

  set_type :recommendation_recommendations
end
