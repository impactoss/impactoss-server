# frozen_string_literal: true

class CreateTokenActivities < ActiveRecord::Migration[8.0]
  def up
    create_table :token_activities do |t|
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.string :client_id, null: false
      t.datetime :last_activity_at, null: false
      t.timestamps
    end

    add_index :token_activities, [:user_id, :client_id],
      unique: true,
      name: "index_token_activities_on_user_and_client"
  end

  def down
    drop_table :token_activities
  end
end
