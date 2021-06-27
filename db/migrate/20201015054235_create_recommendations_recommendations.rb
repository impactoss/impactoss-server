class CreateRecommendationsRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendations_recommendations do |t|
      t.integer :recommendation_id
      t.integer :other_recommendation_id
    end

    add_foreign_key :recommendations_recommendations, :recommendations, column: :recommendation_id
    add_foreign_key :recommendations_recommendations, :recommendations, column: :other_recommendation_id
  end
end
