class CreateRecommendationCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendation_categories do |t|
      t.integer :recommendation_id
      t.integer :category_id

      t.timestamps
    end
  end
end
