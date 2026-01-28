class CreateProgressReports < ActiveRecord::Migration[5.0]
  def change
    create_table :progress_reports do |t|
      t.integer :indicator_id
      t.integer :due_date_id
      t.string :title
      t.text :description
      t.string :document_url
      t.boolean :document_public
      t.boolean :draft

      t.timestamps
    end
    add_index :progress_reports, :indicator_id
    add_index :progress_reports, :due_date_id
  end
end
