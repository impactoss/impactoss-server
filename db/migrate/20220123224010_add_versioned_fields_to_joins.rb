class AddVersionedFieldsToJoins < ActiveRecord::Migration[6.1]
  def change
    change_table(:measure_categories) do |t|
      t.belongs_to :updated_by, foreign_key: {to_table: "users"}, index: true, null: true
    end
  end
end
