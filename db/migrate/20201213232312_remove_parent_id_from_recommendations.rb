class RemoveParentIdFromRecommendations < ActiveRecord::Migration[5.0]
  def change
    remove_column :recommendations, :parent_id, :integer
  end
end
