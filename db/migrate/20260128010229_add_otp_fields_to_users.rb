class AddOtpFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :otp_required_for_login, :boolean, default: false, null: false
    add_column :users, :otp_secret, :string
    add_column :users, :multi_factor_email_code, :string
    add_column :users, :multi_factor_email_code_enabled, :boolean, default: false, null: false
    add_column :users, :multi_factor_email_code_sent_at, :datetime
  end
end
