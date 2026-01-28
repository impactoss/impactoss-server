class AddTargetDateCommentToMeasures < ActiveRecord::Migration[5.0]
  def change
    add_column :measures, :target_date_comment, :text
  end
end
