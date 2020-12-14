class RecommendationIndicatorSerializer
  include FastApplicationSerializer

  attributes :recommendation_id, :indicator_id

  set_type :recommendation_indicators
end
