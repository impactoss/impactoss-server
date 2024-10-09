class UserCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user_id, uniqueness: {scope: :category_id}
  validates :user_id, presence: true
  validates :category_id, presence: true
  validate :single_category_per_taxonomy, on: :create

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  # replacing "save": before creating the record we need to remove all
  # previous relationships (there should only be one) between the user
  # and other categories of the same taxonomy
  # also we need to lock the user to ensure that no other category is associated
  def save_with_cleanup
    with_locked_user do
      transaction do
        if category && category.taxonomy&.allow_multiple == false
          self.class.where(
            category_id: category.taxonomy.categories.where.not(id: category.id).pluck(:id),
            user_id: user_id
          ).destroy_all
        end

        save!
      end
    end
  end

  private

  def set_relationship_updated
    if user && !user.destroyed?
      user.update_column(:relationship_updated_at, Time.zone.now)
      user.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end

  def single_category_per_taxonomy
    if category&.taxonomy && !category.taxonomy.allow_multiple
      existing_categories = self.class.where(
        category_id: category.taxonomy.categories.pluck(:id),  # Ensure you're using IDs here
        user_id: user_id
      )

      if existing_categories.count >= 1
        errors.add(:category, "This user already has a category in the same taxonomy. Multiple categories are not allowed for the taxonomy.")
      end
    end
  end

  def with_locked_user
    if user
      user.with_lock do
        yield
      end
    else
      yield
    end
  end
end
