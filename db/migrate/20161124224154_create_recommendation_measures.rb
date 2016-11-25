class CreateRecommendationMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_measures do |t|
      t.belongs_to :recommendation, index: true
      t.belongs_to :measure, index: true
      t.timestamps
    end
  end
end
