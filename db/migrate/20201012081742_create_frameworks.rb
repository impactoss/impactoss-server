class CreateFrameworks < ActiveRecord::Migration[5.0]
  def change
    create_table :frameworks do |t|
      t.text :title, null: false
      t.string :short_title
      t.text :description
      t.boolean :has_indicators
      t.boolean :has_measures
      t.boolean :has_response

      t.timestamps
    end
  end
end
