class ChangeTitleAndDescriptionToText < ActiveRecord::Migration[5.0]
  def change
    change_column :recommendations, :title, :text
    change_column :categories, :title, :text
    change_column :indicators, :title, :text
    change_column :measures, :title, :text
    change_column :progress_reports, :title, :text
    change_column :progress_reports, :title, :text
    change_column :taxonomies, :title, :text
    change_column :categories, :description, :text
    change_column :indicators, :description, :text
  end
end
