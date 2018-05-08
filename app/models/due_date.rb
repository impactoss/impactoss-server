class DueDate < VersionedRecord
  belongs_to :indicator
  has_one :manager, through: :indicator
  has_many :progress_reports

  delegate :manager, to: :indicator, allow_nil: true
  delegate :email, to: :manager, prefix: true, allow_nil: true
  delegate :name, to: :manager, prefix: true, allow_nil: true

  validates :due_date, presence: true

  scope :no_progress_reports, -> { left_outer_joins(:progress_reports).where( progress_reports: { id: nil } ) }
  scope :has_progress_reports, -> { left_outer_joins(:progress_reports).where.not( progress_reports: { id: nil } ) }
  scope :future, -> { where('due_date > ?', Date.today) }
  scope :future_with_no_progress_reports, -> { future.no_progress_reports }
  scope :are_due, -> { no_progress_reports.where('due_date >= ? AND due_date <= ?', Date.today, Date.today + DUE_NUMBER_OF_DAYS.days) }
  scope :are_overdue, -> { no_progress_reports.where('due_date < ?', Date.today) }

  DUE_NUMBER_OF_DAYS = 30.freeze

  def self.send_due_emails
    DueDate.are_due.each do |due_date|
      DueDateMailer.due(due_date).deliver_now
    end
  end

  def self.send_overdue_emails
    DueDate.are_overdue.each do |due_date|
      DueDateMailer.overdue(due_date).deliver_now
    end
  end

  def has_progress_report
    progress_reports.any?
  end

  def due
    !has_progress_report && due_date >= Date.today && due_date <= Date.today + DUE_NUMBER_OF_DAYS.days
  end

  def overdue
    !has_progress_report && due_date < Date.today
  end
end
