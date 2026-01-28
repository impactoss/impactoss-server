class AddReferenceToMeasures < ActiveRecord::Migration[6.1]
  def change
    add_column :measures, :reference, :string, null: true
  end
end
