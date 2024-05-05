class ProgressReport < VersionedRecord
  belongs_to :indicator
  belongs_to :due_date, required: false
  has_many :measures, through: :indicator
  has_many :recommendations, through: :measures
  has_many :categories, through: :recommendations
  has_one :manager, through: :indicator
  delegate :email, to: :manager, prefix: true, allow_nil: true
  delegate :name, to: :manager, prefix: true, allow_nil: true

  validates :title, presence: true
  validates :indicator_id, presence: true

  validate :indicator_id_must_not_change, if: [:persisted?, :indicator_id_changed?]

  def self.send_all_updated_emails
    joins(:versions)
      .where(versions: {
        created_at: 24.hours.ago..,
        whodunnit: User.joins(:roles).where(roles: {name: "contributor"}).pluck(:id)
      })
      .each(&:send_updated_emails)
  end

  private

  def indicator_id_must_not_change
    errors.add(:indicator_id, "cannot be changed after the report has been created")
  end

  def send_updated_emails
    ProgressReportMailer.updated(self).deliver_now
  end
end
