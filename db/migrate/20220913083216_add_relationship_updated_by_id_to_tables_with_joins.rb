class AddRelationshipUpdatedByIdToTablesWithJoins < ActiveRecord::Migration[6.1]
  def change
    add_column :indicators, :relationship_updated_by_id, :bigint, null: true
    add_foreign_key :indicators, :users, column: :relationship_updated_by_id, primary_key: :id

    add_column :measures, :relationship_updated_by_id, :bigint, null: true
    add_foreign_key :measures, :users, column: :relationship_updated_by_id, primary_key: :id

    add_column :users, :relationship_updated_by_id, :bigint, null: true
    add_foreign_key :users, :users, column: :relationship_updated_by_id, primary_key: :id
  end
end
