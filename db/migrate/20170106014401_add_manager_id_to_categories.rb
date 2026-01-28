class AddManagerIdToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :manager_id, :integer
    add_index :categories, :manager_id
  end
end
