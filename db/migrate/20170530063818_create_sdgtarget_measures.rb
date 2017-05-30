class CreateSdgtargetMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :sdgtarget_measures do |t|
      t.integer :sdgtarget_id
      t.integer :measure_id

      t.timestamps
    end
    add_index :sdgtarget_measures, :sdgtarget_id
    add_index :sdgtarget_measures, :measure_id
  end
end
