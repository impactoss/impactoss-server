class AddGroupsSdgtargetsDefaultToTaxonomies < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomies, :groups_sdgtargets_default, :integer
  end
end
