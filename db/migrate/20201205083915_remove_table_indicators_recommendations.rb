class RemoveTableIndicatorsRecommendations < ActiveRecord::Migration[5.0]
  def change
    drop_table :indicators_recommendations
  end
end
