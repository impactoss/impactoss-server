class AddGroupingDefaultToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :grouping_default, :integer
  end
end
