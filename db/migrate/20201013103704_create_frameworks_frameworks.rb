class CreateFrameworksFrameworks < ActiveRecord::Migration[5.0]
  def change
    create_table :frameworks_frameworks do |t|
      t.integer :framework_id
      t.integer :other_framework_id
    end

    add_foreign_key :frameworks_frameworks, :frameworks, column: :framework_id
    add_foreign_key :frameworks_frameworks, :frameworks, column: :other_framework_id
  end
end
