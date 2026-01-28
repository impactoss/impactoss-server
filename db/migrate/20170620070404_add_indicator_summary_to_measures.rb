class AddIndicatorSummaryToMeasures < ActiveRecord::Migration[5.0]
  def change
    add_column :measures, :indicator_summary, :text
  end
end
