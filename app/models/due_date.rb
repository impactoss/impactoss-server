class DueDate < ApplicationRecord
  has_paper_trail

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

  DUE_NUMBER_OF_DAYS = 30.freeze

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
