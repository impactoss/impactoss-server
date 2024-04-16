class AddRelationshipUpdatedAtToRecommendations < ActiveRecord::Migration[6.1]
  def change
    add_column :recommendations, :relationship_updated_at, :datetime, precision: 6, null: true
  end
end
