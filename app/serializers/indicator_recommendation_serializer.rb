class IndicatorRecommendationSerializer
  include FastVersionedSerializer

  attributes :indicator_id, :recommendation_id

  set_type :indicators_recommendations
end
