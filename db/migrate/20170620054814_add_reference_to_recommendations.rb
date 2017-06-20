class AddReferenceToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :reference, :text, null: false
  end
end
