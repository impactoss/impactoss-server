class AddTimestampsToRecommendationRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :recommendation_recommendations
  end
end
