class AddUserOnlyToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :user_only, :boolean
  end
end
