class AddLastModifiedUserIdToVersionedRecords < ActiveRecord::Migration[5.0]
  def up
    VERSIONED_MODELS.each do |model|
      add_column model.table_name, :last_modified_user_id, :integer

      model.reset_column_information

      model.find_each do |record|
        if record.versions.last
          record.update_column(:last_modified_user_id, record.versions.last.whodunnit)
        end
      end
    end
  end

  def down
    VERSIONED_MODELS.each do |model|
      remove_column model.table_name, :last_modified_user_id
    end
  end

  private

  VERSIONED_MODELS = [
    Category,
    DueDate,
    Indicator,
    Measure,
    Page,
    ProgressReport,
    Recommendation,
    Sdgtarget,
    Taxonomy,
    User,
    UserRole
  ]
end
