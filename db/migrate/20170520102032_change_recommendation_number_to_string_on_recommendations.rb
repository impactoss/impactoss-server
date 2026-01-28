class ChangeRecommendationNumberToStringOnRecommendations < ActiveRecord::Migration[5.0]
  def change
    change_column :recommendations, :number, :string
  end
end
