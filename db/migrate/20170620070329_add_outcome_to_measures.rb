class AddOutcomeToMeasures < ActiveRecord::Migration[5.0]
  def change
    add_column :measures, :outcome, :text
  end
end
