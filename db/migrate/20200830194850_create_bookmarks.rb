class CreateBookmarks < ActiveRecord::Migration[5.0]
  def change
    create_table :bookmarks do |t|
      t.belongs_to :user, index: true, null: false

      t.string :title, null: false
      t.json :view, null: false

      t.integer :last_modified_user_id
      t.timestamps
    end
  end
end
