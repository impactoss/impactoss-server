class SdgtargetRecommendationSerializer
  include FastApplicationSerializer

  attributes :sdgtarget_id, :recommendation_id

  set_type :sdgtarget_recommendations
end
