class Page < VersionedRecord
  validates :title, presence: true
end
