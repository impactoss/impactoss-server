class AddDraftToIndicator < ActiveRecord::Migration[5.0]
  def change
    add_column :indicators, :draft, :boolean, default: false
    add_index :indicators, :draft
  end
end
