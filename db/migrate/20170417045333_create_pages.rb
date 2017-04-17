class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.string :title
      t.text :content
      t.string :menu_title
      t.boolean :draft, default: false

      t.timestamps
    end
    add_index :pages, :draft
  end
end
