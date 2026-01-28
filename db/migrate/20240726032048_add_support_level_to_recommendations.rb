class AddSupportLevelToRecommendations < ActiveRecord::Migration[6.1]
  def change
    add_column :recommendations, :support_level, :integer
  end
end
