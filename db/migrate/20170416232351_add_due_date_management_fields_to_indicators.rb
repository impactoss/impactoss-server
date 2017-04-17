class AddDueDateManagementFieldsToIndicators < ActiveRecord::Migration[5.0]
  def change
    add_column :indicators, :frequency_months, :integer
    add_column :indicators, :start_date, :date
    add_column :indicators, :repeat, :boolean, default: false
    add_column :indicators, :end_date, :date
  end
end
