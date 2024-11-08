class CreateRolePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :role_permissions do |t|
      t.references :permission, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.datetime :revoked_at
      t.references :updated_by, foreign_key: {to_table: :users}
      t.timestamps
    end
  end
end
