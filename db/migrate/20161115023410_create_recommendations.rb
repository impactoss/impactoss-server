class CreateRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendations do |t|
      t.string :title, null: false
      t.integer :number, null: false

      t.timestamps
    end
  end
end
