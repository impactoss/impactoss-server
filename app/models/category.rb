class Category < VersionedRecord
  belongs_to :taxonomy
  belongs_to :category, class_name: "Category", foreign_key: :parent_id, optional: true
  belongs_to :manager, class_name: "User", foreign_key: :manager_id, optional: true, inverse_of: :categories
  has_many :categories, foreign_key: :parent_id, class_name: "Category"
  has_many :recommendation_categories, inverse_of: :category, dependent: :destroy
  has_many :user_categories, inverse_of: :category, dependent: :destroy
  has_many :measure_categories, inverse_of: :category, dependent: :destroy
  has_many :recommendations, through: :recommendation_categories
  has_many :users, through: :user_categories
  has_many :measures, through: :measure_categories

  delegate :name, :email, to: :manager, prefix: true, allow_nil: true

  validates :title, presence: true

  validate :sub_relation
  validate :only_manager_and_admin_users_can_be_assigned, if: :manager_id_changed?

  scope :draft, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }

  def combined_indicator_ids
    (
      recommendations.flat_map(&:indicator_ids) +
      categories.flat_map(&:combined_indicator_ids)
    ).uniq
  end

  def due_dates
    DueDate.where(indicator_id: combined_indicator_ids)
  end

  def disallowed_sibling_category_ids
    return [] if taxonomy.allow_multiple

    taxonomy.categories.where.not(id: id).pluck(:id)
  end

  def has_reporting_cycle_taxonomy?
    Taxonomy.current_reporting_cycle_id == taxonomy_id
  end

  def is_current
    has_reporting_cycle_taxonomy? &&
      (draft ||
        (category.present? &&
          (category.categories.published.length == 1 ||
            (date.present? &&
              category.categories.published.order(date: :desc).first == self
            )
          )
        )
      )
  end

  def only_manager_and_admin_users_can_be_assigned
    return if manager_id.nil? || manager.role?("admin") || manager.role?("manager")

    errors.add(:manager_id, "must be a manager or an admin")
  end

  def sub_relation
    if parent_id.present?
      parent_category = Category.find(parent_id)

      if !parent_category.parent_id.nil?
        errors.add(:parent_id, "Parent category is already a sub-category.")
        return
      end

      parent_taxonomy_id = Taxonomy.find(taxonomy_id).parent_id
      parent_category_taxonomy_id = parent_category.taxonomy_id

      if parent_category_taxonomy_id != parent_taxonomy_id
        errors.add(:parent_id, "Taxonomy does not have parent category's taxonomy as parent.")
      end
    end
  end

  def self_and_ancestors
    return [self] if parent_id.nil?

    [self, *category.self_and_ancestors]
  end

  def self.send_all_due_emails
    Category.all.each(&:send_due_emails)
  end

  def self.send_all_overdue_emails
    Category.all.each(&:send_overdue_emails)
  end

  def send_due_emails
    due_dates.are_due.each do |due_date|
      DueDateMailer.category_due(due_date, self).deliver_now
    end
  end

  def send_overdue_emails
    due_dates.are_overdue.each do |due_date|
      DueDateMailer.category_overdue(due_date, self).deliver_now
    end
  end
end
