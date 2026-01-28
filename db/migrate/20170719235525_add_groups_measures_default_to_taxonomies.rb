class AddGroupsMeasuresDefaultToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :groups_measures_default, :integer
  end
end
