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
    #
    # Reads users.tokens directly and inserts via the connection rather than
    # going through the User/TokenActivity models, so a replay from scratch
    # does not depend on either model's current shape (a default scope, a
    # required column, a rename).
    now = Time.current
    columns = %w[user_id client_id last_activity_at created_at updated_at]
    batch_size = 1000
    rows = []

    flush = lambda do
      next if rows.empty?

      values = rows.map { |row| "(#{columns.map { |c| quote(row[c]) }.join(", ")})" }.join(", ")
      execute("INSERT INTO token_activities (#{columns.join(", ")}) VALUES #{values}")
      rows = []
    end

    select_all("SELECT id, tokens FROM users WHERE tokens IS NOT NULL").each do |row|
      tokens = JSON.parse(row["tokens"])
      next if tokens.blank?

      tokens.each_key do |client_id|
        rows << {
          "user_id" => row["id"],
          "client_id" => client_id,
          "last_activity_at" => now,
          "created_at" => now,
          "updated_at" => now
        }
        flush.call if rows.size >= batch_size
      end
    end
    flush.call
  end

  def down
    drop_table :token_activities
  end
end
