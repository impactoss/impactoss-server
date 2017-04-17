class DueDate < ApplicationRecord
  has_paper_trail

  belongs_to :indicator
  has_one :manager, through: :indicator
  has_many :progress_reports

  validates :due_date, presence: true

  scope :no_progress_reports, -> { left_outer_joins(:progress_reports).where( progress_reports: { id: nil } ) }
  scope :has_progress_reports, -> { left_outer_joins(:progress_reports).where.not( progress_reports: { id: nil } ) }
end
