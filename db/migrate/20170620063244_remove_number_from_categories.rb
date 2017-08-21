class RemoveNumberFromCategories < ActiveRecord::Migration[5.0]
  def change
    remove_column :categories, :number, :integer
  end
end
