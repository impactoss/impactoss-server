class CreateTaxonomies < ActiveRecord::Migration[5.0]
  def change
    create_table :taxonomies do |t|
      t.string :title, null: false
      t.boolean :tags_recommendations
      t.boolean :tags_measures

      t.timestamps
    end
  end
end
