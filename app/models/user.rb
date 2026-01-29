# frozen_string_literal: true

class User < VersionedRecord
  #  :omniauthable
  include DeviseTokenAuth::Concerns::User

  # Include default devise modules with security extensions
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # Added: :lockable, :password_expirable, :password_archivable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :lockable, :password_expirable, :password_archivable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :managed_categories, foreign_key: :manager_id, class_name: "Category"
  has_many :managed_indicators, foreign_key: :manager_id, class_name: "Indicator"
  has_many :user_categories
  has_many :categories, through: :user_categories
  has_many :bookmarks

  belongs_to :relationship_updated_by, class_name: "User", required: false

  validates :email, presence: true
  validates :name, presence: true

  # secure password validation
  validates :password, secure_password: true, if: :password_required?

  # Track date of password change for expiry feature
  before_update :set_password_changed_at, if: :saved_change_to_encrypted_password?

  def has_any_role?(role_names)
    return false if roles.empty?

    role_names.any? do |role_name|
      if Permissions::ROLE_HIERARCHY.key?(role_name)
        role?(role_name)
      else
        roles.exists?(name: role_name)
      end
    end
  end

  def role?(role_name)
    # For hierarchical roles, check level
    if Permissions::ROLE_HIERARCHY.key?(role_name)
      required_level = Permissions::ROLE_HIERARCHY[role_name]

      roles.any? do |user_role|
        user_level = Permissions::ROLE_HIERARCHY[user_role.name]
        user_level && user_level >= required_level
      end
    else
      # For non-hierarchical roles (or roles not in hierarchy), check exact match
      roles.exists?(name: role_name)
    end
  end

  def domain
    email.to_s.split("@").last
  end

  private

  # Set timestamp when password changes
  def set_password_changed_at
    self.password_changed_at = Time.current
  end
end
