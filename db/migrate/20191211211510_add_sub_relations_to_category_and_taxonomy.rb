class AddSubRelationsToCategoryAndTaxonomy < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :parent_id, :integer
    add_column :taxonomies, :has_date, :boolean
    
    add_column :categories, :parent_id, :integer
    add_column :categories, :date, :date
  end
end
