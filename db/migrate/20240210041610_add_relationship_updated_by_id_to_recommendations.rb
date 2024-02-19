class AddRelationshipUpdatedByIdToRecommendations < ActiveRecord::Migration[6.1]
  def change
    add_column :recommendations, :relationship_updated_by_id, :bigint, null: true
    add_foreign_key :recommendations, :users, column: :relationship_updated_by_id, primary_key: :id
  end
end
