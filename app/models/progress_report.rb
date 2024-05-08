class ProgressReport < VersionedRecord
  belongs_to :indicator
  belongs_to :due_date, required: false
  has_many :measures, through: :indicator
  has_many :recommendations, through: :measures
  has_many :categories, through: :recommendations
  has_one :manager, through: :indicator

  validates :title, presence: true
  validates :indicator_id, presence: true

  validate :indicator_id_must_not_change, if: [:persisted?, :indicator_id_changed?]

  def self.send_all_updated_emails
    where(updated_at: 24.hours.ago..)
      .each(&:send_updated_emails)
  end

  def send_updated_emails
    categories
      .reject { _1.updated_by_id == _1.manager_id }
      .each do |category|
        ProgressReportMailer.updated(self, category).deliver_now
      end
  end

  private

  def indicator_id_must_not_change
    errors.add(:indicator_id, "cannot be changed after the report has been created")
  end
end
