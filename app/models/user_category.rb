class UserCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user_id, uniqueness: {scope: :category_id}
  validates :user_id, presence: true
  validates :category_id, presence: true

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def set_relationship_updated_at
    user.update_column(:relationship_updated_at, Time.zone.now) if user && !user.destroyed?
  end
end
