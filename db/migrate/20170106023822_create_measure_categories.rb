class CreateMeasureCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :measure_categories do |t|
      t.integer :measure_id
      t.integer :category_id

      t.timestamps
    end
  end
end
