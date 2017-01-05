class AddDraftToCategory < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :draft, :boolean, default: false
    add_index :categories, :draft
  end
end
