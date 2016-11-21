class CreateRecommendationIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_indicators do |t|
      t.belongs_to :recommendation, index: true
      t.belongs_to :indicator, index: true
      t.timestamps
    end
  end
end
