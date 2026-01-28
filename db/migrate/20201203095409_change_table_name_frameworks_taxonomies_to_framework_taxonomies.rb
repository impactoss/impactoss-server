class ChangeTableNameFrameworksTaxonomiesToFrameworkTaxonomies < ActiveRecord::Migration[5.0]
  def change
    rename_table :frameworks_taxonomies, :framework_taxonomies
  end
end
