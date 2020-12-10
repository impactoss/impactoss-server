class AddFrameworkIdToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_reference :taxonomies, :framework, index: true, foreign_key: true
  end
end
