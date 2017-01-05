class AddDraftToTaxonomy < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :draft, :boolean, default: false
    add_index :taxonomies, :draft
  end
end
