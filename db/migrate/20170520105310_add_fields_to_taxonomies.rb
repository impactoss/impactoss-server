class AddFieldsToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :priority, :integer
    add_column :taxonomies, :tags_sdgtargets, :boolean
    add_column :taxonomies, :is_smart, :boolean
  end
end
