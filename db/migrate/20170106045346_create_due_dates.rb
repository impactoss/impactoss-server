class CreateDueDates < ActiveRecord::Migration[5.0]
  def change
    create_table :due_dates do |t|
      t.integer :indicator_id
      t.date :due_date

      t.timestamps
    end
    add_index :due_dates, :indicator_id
  end
end
