class AddRecommendationIndicatorsIndexesAndForeignKeys < ActiveRecord::Migration[5.0]
  def change
    add_index :recommendation_indicators, :recommendation_id
    add_index :recommendation_indicators, :indicator_id
    add_foreign_key :recommendation_indicators, :recommendations
    add_foreign_key :recommendation_indicators, :indicators
  end
end
