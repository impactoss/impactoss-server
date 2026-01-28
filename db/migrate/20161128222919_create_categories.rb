class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :title
      t.string :short_title
      t.string :description
      t.string :url

      t.belongs_to :taxonomy

      t.timestamps
    end
  end
end
