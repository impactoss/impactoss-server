class AddTagsUsersToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :tags_users, :boolean
  end
end
