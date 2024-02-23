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

  private

  def indicator_id_must_not_change
    errors.add(:indicator_id, "cannot be changed after the report has been created")
  end
end
