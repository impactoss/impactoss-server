class AddAllowMultipleToTaxonomy < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :allow_multiple, :bool
  end
end
