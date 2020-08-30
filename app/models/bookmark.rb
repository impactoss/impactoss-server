class Bookmark < VersionedRecord
  enum type: [ :actions, :recommendations, :sdg_targets, :sds_key_outcomes ]

  validates :type, presence: true
  validates :title, presence: true
  validates :view, presence: true
end
