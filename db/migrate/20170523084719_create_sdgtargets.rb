class CreateSdgtargets < ActiveRecord::Migration[5.0]
  def change
    create_table :sdgtargets do |t|
      t.string :reference
      t.text :title
      t.text :description
      t.boolean :draft, default: false

      t.timestamps
    end
    add_index :sdgtargets, :draft
  end
end
