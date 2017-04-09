class AddHasManagerToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :has_manager, :boolean, default: false
  end
end
