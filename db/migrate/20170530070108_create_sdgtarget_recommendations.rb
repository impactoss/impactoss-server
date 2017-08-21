class CreateSdgtargetRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :sdgtarget_recommendations do |t|
      t.integer :sdgtarget_id
      t.integer :recommendation_id

      t.timestamps
    end
    add_index :sdgtarget_recommendations, :sdgtarget_id
    add_index :sdgtarget_recommendations, :recommendation_id
  end
end
