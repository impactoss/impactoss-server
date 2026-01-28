class CreateRecommendationIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_indicators do |t|
      t.integer :recommendation_id
      t.integer :indicator_id

      t.timestamps
    end
  end
end
