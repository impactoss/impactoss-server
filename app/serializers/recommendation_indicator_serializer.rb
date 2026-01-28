class RecommendationIndicatorSerializer
  include FastVersionedSerializer

  attributes :recommendation_id, :indicator_id

  set_type :recommendation_indicators
end
