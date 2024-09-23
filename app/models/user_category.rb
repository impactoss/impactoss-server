class UserCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user_id, uniqueness: {scope: :category_id}
  validates :user_id, presence: true
  validates :category_id, presence: true

  around_save :enforce_allow_multiple
  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def enforce_allow_multiple
    yield and return unless category && category.taxonomy&.allow_multiple == false

    transaction do
      yield
      self.class.where(
        category_id: category.taxonomy.categories.where.not(id: category_id).pluck(:id),
        user_id: user_id
      ).destroy_all
    end
  end

  def set_relationship_updated
    if user && !user.destroyed?
      user.update_column(:relationship_updated_at, Time.zone.now)
      user.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
