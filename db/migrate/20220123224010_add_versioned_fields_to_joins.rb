class AddVersionedFieldsToJoins < ActiveRecord::Migration[6.1]
  def change
    %i[
      measure_categories
      measure_indicators
      recommendation_categories
      recommendation_indicators
      recommendation_measures
      recommendation_recommendations
      user_categories
    ].each do |table_name|
      change_table(table_name) do |t|
        t.belongs_to :updated_by, foreign_key: {to_table: "users"}, index: true, null: true
      end
    end
  end
end
