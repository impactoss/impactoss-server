class AddReferenceToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :reference, :string
  end
end
