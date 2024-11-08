class RolePermission < VersionedRecord
  belongs_to :permission
  belongs_to :role

  validates :permission, presence: true
  validates :role, presence: true

  scope :active, -> { where(revoked_at: nil) }
end
