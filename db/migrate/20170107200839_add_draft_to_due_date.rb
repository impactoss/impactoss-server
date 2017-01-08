class AddDraftToDueDate < ActiveRecord::Migration[5.0]
  def change
    add_column :due_dates, :draft, :boolean, default: false
    add_index :due_dates, :draft
  end
end
