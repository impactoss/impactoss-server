class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false, unique: true
      t.string :friendly_name, null: false
      t.timestamps null: false
    end

    create_table :user_roles do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :role, index: true, null: false
      t.timestamps null: false
    end
  end
end
