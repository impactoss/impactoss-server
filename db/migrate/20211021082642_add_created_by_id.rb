class AddCreatedById < ActiveRecord::Migration[6.1]
  def change
    add_column :bookmarks, :created_by_id, :integer
    add_column :categories, :created_by_id, :integer
    add_column :due_dates, :created_by_id, :integer
    add_column :framework_frameworks, :created_by_id, :integer
    add_column :framework_taxonomies, :created_by_id, :integer
    add_column :frameworks, :created_by_id, :integer
    add_column :indicators, :created_by_id, :integer
    add_column :measure_categories, :created_by_id, :integer
    add_column :measure_indicators, :created_by_id, :integer
    add_column :measures, :created_by_id, :integer
    add_column :pages, :created_by_id, :integer
    add_column :progress_reports, :created_by_id, :integer
    add_column :recommendation_categories, :created_by_id, :integer
    add_column :recommendation_indicators, :created_by_id, :integer
    add_column :recommendation_measures, :created_by_id, :integer
    add_column :recommendation_recommendations, :created_by_id, :integer
    add_column :recommendations, :created_by_id, :integer
    add_column :roles, :created_by_id, :integer
    add_column :sdgtarget_categories, :created_by_id, :integer
    add_column :sdgtarget_indicators, :created_by_id, :integer
    add_column :sdgtarget_measures, :created_by_id, :integer
    add_column :sdgtarget_recommendations, :created_by_id, :integer
    add_column :sdgtargets, :created_by_id, :integer
    add_column :taxonomies, :created_by_id, :integer
    add_column :user_categories, :created_by_id, :integer
    add_column :user_roles, :created_by_id, :integer
    add_column :users, :created_by_id, :integer
  end
end
