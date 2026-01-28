class CreateFrameworksTaxonomies < ActiveRecord::Migration[5.0]
  def change
    create_join_table :frameworks, :taxonomies do |t|
      t.index :framework_id
      t.index :taxonomy_id
    end

    add_foreign_key :frameworks_taxonomies, :frameworks
    add_foreign_key :frameworks_taxonomies, :taxonomies
  end
end
