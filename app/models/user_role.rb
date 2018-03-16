class UserRole < VersionedRecord
  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: :role_id }

  delegate :name, to: :role, prefix: true, allow_nil: true
end
