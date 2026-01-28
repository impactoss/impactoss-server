class ChangeTableNameFrameworksFrameworksToFrameworkFrameworks < ActiveRecord::Migration[5.0]
  def change
    rename_table :frameworks_frameworks, :framework_frameworks
  end
end
