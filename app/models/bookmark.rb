class Bookmark < VersionedRecord
  belongs_to :user

  validates :title, presence: true
  validates :view, presence: true
end
