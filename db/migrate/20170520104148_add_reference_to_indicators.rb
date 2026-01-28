class AddReferenceToIndicators < ActiveRecord::Migration[5.0]
  def change
    add_column :indicators, :reference, :string
  end
end
