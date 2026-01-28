class CreateIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :indicators do |t|
      t.string :title, null: false
      t.string :description
      t.timestamps
    end
  end
end
