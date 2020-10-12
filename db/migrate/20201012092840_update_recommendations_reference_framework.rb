class UpdateRecommendationsReferenceFramework < ActiveRecord::Migration[5.0]
  def change
    add_reference :recommendations, :framework, index: true, foreign_key: true
  end
end
