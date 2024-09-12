class MakeReferenceAndTitleFieldsMandatory < ActiveRecord::Migration[6.1]
  def change
    change_column_null :measures, :reference, false, ""
    change_column_null :indicators, :reference, false, ""
    change_column_null :pages, :title, false, ""
    change_column_null :categories, :title, false, ""
    change_column_null :progress_reports, :title, false, ""
  end
end
