class UpdateTaxonomiesReferenceFramework < ActiveRecord::Migration[5.0]
  def change
    remove_column :taxonomies, :tags_recommendations, :boolean
    remove_column :taxonomies, :tags_sdgtargets, :boolean

    add_reference :taxonomies, :framework, index: true, foreign_key: true
  end
end
