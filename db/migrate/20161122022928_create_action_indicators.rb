class CreateActionIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :action_indicators do |t|
      t.integer  :action_id
      t.integer  :indicator_id
      t.timestamps
    end
  end
end
