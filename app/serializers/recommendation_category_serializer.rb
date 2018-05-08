class RecommendationCategorySerializer
  include FastApplicationSerializer

  attributes :recommendation_id, :category_id

  set_type :recommendation_categories
end
