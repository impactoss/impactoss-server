class RemoveGroupingDefaultFromTaxonomies < ActiveRecord::Migration[5.0]
  def change
    remove_column :taxonomies, :grouping_default, :integer
  end
end
