class Indicator < VersionedRecord
  # No ResetsCurrentCycle here: the resolver never reads an Indicator
  # attribute, only MeasureIndicator rows (see current_cycle.rb), which
  # invalidate it on create and on destroy of the join record itself -
  # reassigning `measures=` removes stale join rows via delete_all, which
  # fires neither, so that path relies on nothing already having warmed the
  # resolver in the same unit of work.

  validates :title, presence: true
  validates :end_date, presence: true, if: :repeat?
  validates :frequency_months, presence: true, if: :repeat?
  validates :reference, presence: true, uniqueness: true
  validate :end_date_after_start_date, if: :end_date?
  validate :responsible_has_required_role, if: :manager_id_changed?

  after_create :build_due_dates
  after_update :regenerate_due_dates

  has_many :measure_indicators, inverse_of: :indicator, dependent: :destroy
  has_many :recommendation_indicators, inverse_of: :indicator, dependent: :destroy
  has_many :recommendations, through: :recommendation_indicators
  has_many :progress_reports
  has_many :due_dates
  has_many :measures, through: :measure_indicators, inverse_of: :indicators
  has_many :categories, through: :measures
  has_many :recommendations, through: :measures

  # not sure we need this?
  # has_many :direct_recommendations, through: :indicators_recommendations, source: :recommendation

  belongs_to :manager, class_name: "User", foreign_key: :manager_id, required: false
  belongs_to :relationship_updated_by, class_name: "User", required: false

  # Current with no measures, or when any of them is current.
  def is_current
    Current.cycle.indicator_current?(id)
  end

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
        due_dates.find_or_create_by!(due_date: date_iterator)
        date_iterator += frequency_months.months
      end
    elsif start_date # No repeating
      due_dates.find_or_create_by!(due_date: start_date)
    end
  end

  def regenerate_due_dates
    return unless saved_change_to_start_date? || saved_change_to_end_date? || saved_change_to_frequency_months? || saved_change_to_repeat?
    due_dates.future_with_no_progress_reports.destroy_all
    build_due_dates
    true
  end

  def responsible_has_required_role
    return if manager_id.nil?

    allowed_roles = Permissions.allowed_for("indicator", "assign_as_responsible")
    return if manager.has_any_role?(allowed_roles)

    errors.add(:manager_id, "must have one of these roles: #{allowed_roles.join(", ")}")
  end
end
