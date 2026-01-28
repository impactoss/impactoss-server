class EnforceReferenceUniquenessOnIndicatorsMeasuresRecommendations < ActiveRecord::Migration[6.1]
  def change
    add_index :indicators, :reference, unique: true
    add_index :measures, :reference, unique: true
    add_index :recommendations, :reference, unique: true
  end
end
