class Framework < ApplicationRecord
  has_many :framework_frameworks, :foreign_key => 'framework_id', :class_name => 'FrameworkFramework'
  has_many :frameworks, :through => :framework_frameworks, :source => :other_framework

  has_many :framework_taxonomies, :class_name => 'FrameworkTaxonomy', inverse_of: :framework, dependent: :destroy
  has_many :taxonomies, through: :framework_taxonomies

  has_many :recommendations

  validates :title, presence: true
end
