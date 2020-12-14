class UpdateTaxonomiesRemoveColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :taxonomies, :tags_recommendations, :boolean
    remove_column :taxonomies, :tags_sdgtargets, :boolean
  end
end
