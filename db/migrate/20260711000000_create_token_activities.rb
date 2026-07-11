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

    # Backfill one row per existing live token so currently signed-in users are
    # not force-expired on deploy: enforcement fails closed on a missing row.
    # Seed with the deploy time rather than each token's own updated_at - an old
    # updated_at would immediately expire an otherwise-active session.
    now = Time.current
    rows = []
    User.reset_column_information
    User.find_each do |user|
      next if user.tokens.blank?

      user.tokens.each_key do |client_id|
        rows << {
          user_id: user.id,
          client_id: client_id,
          last_activity_at: now,
          created_at: now,
          updated_at: now
        }
      end
    end
    TokenActivity.insert_all(rows) if rows.any?
  end

  def down
    drop_table :token_activities
  end
end
