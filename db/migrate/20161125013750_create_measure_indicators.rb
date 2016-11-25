class CreateMeasureIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :measure_indicators do |t|
      t.integer  :measure_id
      t.integer  :indicator_id
      t.timestamps
    end
  end
end
