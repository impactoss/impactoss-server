# frozen_string_literal: true

class User < VersionedRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
  #  :omniauthable
  include DeviseTokenAuth::Concerns::User

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
end
