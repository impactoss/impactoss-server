class Category < VersionedRecord
  belongs_to :taxonomy
  belongs_to :manager, class_name: User, foreign_key: :manager_id, optional: true, inverse_of: :categories
  has_many :recommendation_categories, inverse_of: :category, dependent: :destroy
  has_many :user_categories, inverse_of: :category, dependent: :destroy
  has_many :measure_categories, inverse_of: :category, dependent: :destroy
  has_many :sdgtarget_categories, inverse_of: :category, dependent: :destroy
  has_many :recommendations, through: :recommendation_categories
  has_many :users, through: :user_categories
  has_many :measures, through: :measure_categories
  has_many :indicators, through: :recommendations
  has_many :progress_reports, through: :indicators
  has_many :due_dates,-> { uniq }, through: :indicators

  delegate :name, :email, to: :manager, prefix: true, allow_nil: true

  validates :title, presence: true

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
