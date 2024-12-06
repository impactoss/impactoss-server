class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions do |t|
      t.string :operation, null: false
      t.string :resource, null: false
      t.string :status, null: false
      t.datetime :organisation_only_at
      t.datetime :publicly_allowed_at
      t.datetime :user_only_at
      t.timestamps
    end
  end
end
