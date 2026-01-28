class AddFieldsToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :accepted, :boolean
    add_column :recommendations, :response, :text
  end
end
