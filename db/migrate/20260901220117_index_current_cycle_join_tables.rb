# frozen_string_literal: true

# recommendation_categories and measure_indicators back CurrentCycle's hot
# queries (see app/models/current_cycle.rb) but, unlike recommendation_measures,
# were never indexed on either foreign key - every lookup by category_id,
# recommendation_id, measure_id or indicator_id is a sequential scan.
class IndexCurrentCycleJoinTables < ActiveRecord::Migration[8.0]
  def change
    add_index :recommendation_categories, :category_id
    add_index :recommendation_categories, :recommendation_id
    add_index :measure_indicators, :measure_id
    add_index :measure_indicators, :indicator_id
  end
end
