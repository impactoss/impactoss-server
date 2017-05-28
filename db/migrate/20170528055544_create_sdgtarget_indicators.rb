class CreateSdgtargetIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :sdgtarget_indicators do |t|
      t.integer :sdgtarget_id
      t.integer :indicator_id

      t.timestamps
    end
    add_index :sdgtarget_indicators, :sdgtarget_id
    add_index :sdgtarget_indicators, :indicator_id
  end
end
