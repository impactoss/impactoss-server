class SetDefaultDraftTrue < ActiveRecord::Migration[8.0]
  def change
    change_column_default :categories, :draft, from: false, to: true
    change_column_default :indicators, :draft, from: false, to: true
    change_column_default :measures, :draft, from: false, to: true
    change_column_default :pages, :draft, from: false, to: true
    change_column_default :progress_reports, :draft, from: false, to: true
    change_column_default :recommendations, :draft, from: false, to: true
  end
end
