class UserCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user_id, uniqueness: {scope: :category_id}
  validates :user_id, presence: true
  validates :category_id, presence: true

  after_commit :enforce_allow_multiple_from_taxonomy, on: [:create, :update]
  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def disallow_multiple?
    self.class
      .joins(category: :taxonomy)
      .where({
        user_id: user_id,
        category: {
          taxonomies: {allow_multiple: false}
        }
      })
      .count > 0
  end

  def enforce_allow_multiple_from_taxonomy
    if disallow_multiple?
      others_on_user.destroy_all
    end
  end

  def others_on_user
    self.class.where(user_id: user_id).where.not(category_id: category_id)
  end

  def set_relationship_updated
    if user && !user.destroyed?
      user.update_column(:relationship_updated_at, Time.zone.now)
      user.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
