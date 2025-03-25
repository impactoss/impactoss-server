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

  def role?(role)
    roles.where(name: role).any?
  end

  def domain
    email.to_s.split("@").last
  end

  def self.paper_trail_ignored_columns = [:tokens, :updated_at]
end
