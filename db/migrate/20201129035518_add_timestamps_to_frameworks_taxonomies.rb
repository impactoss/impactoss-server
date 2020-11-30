class AddTimestampsToFrameworksTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :frameworks_taxonomies
  end
end
