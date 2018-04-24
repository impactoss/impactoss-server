class IndexIndicatorsOnCreatedAt < ActiveRecord::Migration[5.0]
  def change
    add_index :indicators, :created_at
  end
end
