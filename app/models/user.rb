# frozen_string_literal: true
class User < ApplicationRecord
  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :managed_categories, foreign_key: :manager_id, class_name: Category
  has_many :managed_indicators, foreign_key: :manager_id, class_name: Indicator
  has_many :user_categories
  has_many :categories, through: :user_categories

  validates :name, presence: true
  validates :email, presence: true

  def role?(role)
    roles.where(name: role).any?
  end
end
