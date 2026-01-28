class AddManagerIdToIndicator < ActiveRecord::Migration[5.0]
  def change
    add_column :indicators, :manager_id, :integer
    add_index :indicators, :manager_id
  end
end
