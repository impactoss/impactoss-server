class AddDescriptionToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :description, :text
  end
end
