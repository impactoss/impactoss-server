class CreateMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :measures do |t|
      t.string :title, null: false
      t.text :description
      t.text :target_date
      t.timestamps
    end
  end
end
