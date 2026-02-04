class CreateBackupCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :backup_codes do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :code_digest, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :backup_codes, :code_digest
  end
end
