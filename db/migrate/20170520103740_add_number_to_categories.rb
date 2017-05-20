class AddNumberToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :number, :integer
  end
end
