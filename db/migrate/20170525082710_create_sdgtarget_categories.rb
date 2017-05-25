class CreateSdgtargetCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :sdgtarget_categories do |t|
      t.integer :sdgtarget_id
      t.integer :category_id

      t.timestamps
    end
  end
end
