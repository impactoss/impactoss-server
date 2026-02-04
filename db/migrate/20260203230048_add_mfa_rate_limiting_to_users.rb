class AddMfaRateLimitingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :mfa_failed_attempts, :integer, default: 0, null: false
    add_column :users, :mfa_locked_until, :datetime
  end
end
