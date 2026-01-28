class AddDraftToRecommendation < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :draft, :boolean, default: false
    add_index :recommendations, :draft
  end
end
