class RemoveMultiFactorEmailCodeEnabledFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :multi_factor_email_code_enabled, :boolean
  end
end
