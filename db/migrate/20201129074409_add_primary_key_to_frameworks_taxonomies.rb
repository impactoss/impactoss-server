class AddPrimaryKeyToFrameworksTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :frameworks_taxonomies, :id, :primary_key
  end
end
