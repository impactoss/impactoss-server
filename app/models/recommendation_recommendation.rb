class RecommendationRecommendation < ApplicationRecord

  belongs_to :recommendation, :foreign_key => "recommendation_id"
  belongs_to :other_recommendation, :foreign_key => "other_recommendation_id", :class_name => "Recommendation"
end
