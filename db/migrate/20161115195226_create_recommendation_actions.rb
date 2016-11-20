class CreateRecommendationActions < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_actions do |t|
      t.belongs_to :recommendation, index: true
      t.belongs_to :action, index: true

      t.timestamps
    end
  end
end
