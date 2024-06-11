class AddIsArchiveToMeasuresAndRecommendationsAndIndicatorsAndProgressReportsAndCategoriesAndPages < ActiveRecord::Migration[6.1]
  def change
    add_column :measures, :is_archive, :boolean, default: false
    add_column :recommendations, :is_archive, :boolean, default: false
    add_column :indicators, :is_archive, :boolean, default: false
    add_column :progress_reports, :is_archive, :boolean, default: false
    add_column :categories, :is_archive, :boolean, default: false
    add_column :pages, :is_archive, :boolean, default: false
  end
end
