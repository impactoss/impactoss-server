class Category < VersionedRecord
  belongs_to :taxonomy
  belongs_to :category, class_name: "Category", foreign_key: :parent_id, optional: true
  belongs_to :manager, class_name: "User", foreign_key: :manager_id, optional: true, inverse_of: :categories
  has_many :categories, foreign_key: :parent_id, class_name: "Category"
  has_many :recommendation_categories, inverse_of: :category, dependent: :destroy
  has_many :user_categories, inverse_of: :category, dependent: :destroy
  has_many :measure_categories, inverse_of: :category, dependent: :destroy
  has_many :sdgtarget_categories, inverse_of: :category, dependent: :destroy
  has_many :recommendations, through: :recommendation_categories
  has_many :users, through: :user_categories
  has_many :measures, through: :measure_categories
  has_many :indicators, through: :recommendations
  has_many :indicators_via_measures, through: :recommendations
  has_many :progress_reports, through: :indicators_via_measures
  has_many :due_dates, -> { distinct }, through: :indicators_via_measures

  has_many :children_due_dates, -> { distinct }, through: :categories, source: :due_dates

  delegate :name, :email, to: :manager, prefix: true, allow_nil: true

  validates :title, presence: true

  validate :sub_relation
  validate :only_manager_and_admin_users_can_be_assigned, if: :manager_id_changed?

  scope :draft, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }

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

    children_due_dates.are_due.each do |due_date|
      DueDateMailer.category_due(due_date, self).deliver_now
    end
  end

  def send_overdue_emails
    due_dates.are_overdue.each do |due_date|
      DueDateMailer.category_overdue(due_date, self).deliver_now
    end

    children_due_dates.are_overdue.each do |due_date|
      DueDateMailer.category_overdue(due_date, self).deliver_now
    end
  end
end
