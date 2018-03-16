# frozen_string_literal: true
class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  has_paper_trail ignore: [:tokens, :updated_at]

  def last_modified_user_id
    return nil unless respond_to?(:versions) && versions.last
    versions.last.whodunnit
  end

  def last_modified_user
    return nil unless last_modified_user_id
    User.find last_modified_user_id
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :managed_categories, foreign_key: :manager_id, class_name: Category
  has_many :managed_indicators, foreign_key: :manager_id, class_name: Indicator
  has_many :user_categories
  has_many :categories, through: :user_categories

  validates :email, presence: true
  validates :name, presence: true

  def role?(role)
    roles.where(name: role).any?
  end
end
