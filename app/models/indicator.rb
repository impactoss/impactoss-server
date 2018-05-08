class Indicator < VersionedRecord
  validates :title, presence: true
  validates :end_date, presence: true, if: :repeat?
  validates :frequency_months, presence: true, if: :repeat?
  validate :end_date_after_start_date, if: :end_date?

  after_create :build_due_dates
  after_update :regenerate_due_dates

  has_many :measure_indicators, inverse_of: :indicator, dependent: :destroy
  has_many :sdgtarget_indicators, inverse_of: :indicator, dependent: :destroy
  has_many :progress_reports
  has_many :due_dates
  has_many :measures, through: :measure_indicators, inverse_of: :indicators
  has_many :categories, through: :measures
  has_many :recommendations, through: :measures

  belongs_to :manager, class_name: User, foreign_key: :manager_id, required: false

  accepts_nested_attributes_for :measure_indicators

  private

  def end_date_after_start_date
    if start_date > end_date
      errors.add(:end_date, "must be after start_date")
    end
  end

  def build_due_dates
    if repeat
      date_iterator = start_date
      while date_iterator <= end_date
        if date_iterator >= Date.today
          due_dates.find_or_create_by!(due_date: date_iterator)
        end
        date_iterator = date_iterator + frequency_months.months
      end
    else # No repeating
      if start_date
        due_dates.find_or_create_by!(due_date: start_date)
      end
    end
  end

  def regenerate_due_dates
    return unless start_date_changed? || end_date_changed? || frequency_months_changed? || repeat_changed?
    due_dates.future_with_no_progress_reports.destroy_all
    build_due_dates
  end
end
