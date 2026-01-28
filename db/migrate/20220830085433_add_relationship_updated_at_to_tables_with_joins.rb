class AddRelationshipUpdatedAtToTablesWithJoins < ActiveRecord::Migration[6.1]
  def change
    add_column :indicators, :relationship_updated_at, :datetime, precision: 6, null: true
    add_column :measures, :relationship_updated_at, :datetime, precision: 6, null: true
    add_column :users, :relationship_updated_at, :datetime, precision: 6, null: true
  end
end
