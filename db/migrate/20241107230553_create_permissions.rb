class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions do |t|
      t.string :operation, null: false
      t.string :resource, null: false
      t.string :status, null: false
      t.datetime :publicly_allowed_at
      t.boolean :organisation_only, default: false
      t.boolean :user_only, default: false
      t.timestamps
    end
  end
end
