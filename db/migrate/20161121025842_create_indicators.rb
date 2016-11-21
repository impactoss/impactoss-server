class CreateIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :indicators do |t|
      t.string :name, null: false, unique: false
      t.string :description
      t.timestamps
    end
  end
end
