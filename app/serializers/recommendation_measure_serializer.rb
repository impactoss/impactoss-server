class RecommendationMeasureSerializer
  include FastApplicationSerializer

  attributes :recommendation_id, :measure_id

  set_type :recommendation_measures
end
