class AddIsArchivedToMeasuresAndRecommendationsAndIndicatorsAndProgressReportsAndCategoriesAndPages < ActiveRecord::Migration[6.1]
  def change
    add_column :measures, :is_archived, :boolean, default: false
    add_column :recommendations, :is_archived, :boolean, default: false
    add_column :indicators, :is_archived, :boolean, default: false
    add_column :progress_reports, :is_archived, :boolean, default: false
    add_column :categories, :is_archived, :boolean, default: false
    add_column :pages, :is_archived, :boolean, default: false
  end
end
