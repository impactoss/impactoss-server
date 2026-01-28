class AddDraftToMeasure < ActiveRecord::Migration[5.0]
  def change
    add_column :measures, :draft, :boolean, default: false
    add_index :measures, :draft
  end
end
