class RemoveNumberFromRecommendations < ActiveRecord::Migration[5.0]
  def change
    remove_column :recommendations, :number, :text
  end
end
