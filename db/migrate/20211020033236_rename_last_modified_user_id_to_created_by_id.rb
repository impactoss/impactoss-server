class RenameLastModifiedUserIdToCreatedById < ActiveRecord::Migration[6.1]
  def change
    rename_column :bookmarks, :last_modified_user_id, :updated_by_id
    rename_column :categories, :last_modified_user_id, :updated_by_id
    rename_column :due_dates, :last_modified_user_id, :updated_by_id
    rename_column :indicators, :last_modified_user_id, :updated_by_id
    rename_column :measures, :last_modified_user_id, :updated_by_id
    rename_column :pages, :last_modified_user_id, :updated_by_id
    rename_column :progress_reports, :last_modified_user_id, :updated_by_id
    rename_column :recommendations, :last_modified_user_id, :updated_by_id
    rename_column :sdgtargets, :last_modified_user_id, :updated_by_id
    rename_column :taxonomies, :last_modified_user_id, :updated_by_id
    rename_column :user_roles, :last_modified_user_id, :updated_by_id
    rename_column :users, :last_modified_user_id, :updated_by_id
  end
end
