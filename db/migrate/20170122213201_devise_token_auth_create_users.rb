class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.0]
  def change
    change_table(:users) do |t|
      t.string :provider, null: false, default: "email"
      t.string :uid, null: false, default: ""

      ## Tokens
      t.json :tokens
    end
  end
end
