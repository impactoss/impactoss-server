class RemoveDraftFromTaxonomy < ActiveRecord::Migration[5.0]
  def change
    remove_column :taxonomies, :draft, :boolean
  end
end
