class UserRole < VersionedRecord
  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: {scope: :role_id}

  delegate :name, to: :role, prefix: true, allow_nil: true

  after_commit :set_relationship_updated_at, on: [:create, :update, :destroy]

  private

  def set_relationship_updated_at
    user.update_column(:relationship_updated_at, Time.zone.now) if user && !user.destroyed?
  end
end
