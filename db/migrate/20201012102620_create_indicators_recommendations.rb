class CreateIndicatorsRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_join_table :indicators, :recommendations do |t|
      t.index :indicator_id
      t.index :recommendation_id
    end

    add_foreign_key :indicators_recommendations, :indicators
    add_foreign_key :indicators_recommendations, :recommendations
  end
end
