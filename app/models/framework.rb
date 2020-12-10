class Framework < ApplicationRecord
  has_many :framework_frameworks, :foreign_key => 'framework_id'
  has_many :frameworks, :through => :framework_frameworks, :source => :other_framework

  has_many :framework_taxonomies, inverse_of: :framework, dependent: :destroy
  has_many :taxonomies, through: :framework_taxonomies

  has_many :recommendations

  validates :title, presence: true
end
