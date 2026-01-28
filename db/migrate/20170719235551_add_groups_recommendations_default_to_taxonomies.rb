class AddGroupsRecommendationsDefaultToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :groups_recommendations_default, :integer
  end
end
