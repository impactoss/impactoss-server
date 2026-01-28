class ChangeTableNameRecommendationsRecommendationsToRecommendationRecommendations < ActiveRecord::Migration[5.0]
  def change
    rename_table :recommendations_recommendations, :recommendation_recommendations
  end
end
