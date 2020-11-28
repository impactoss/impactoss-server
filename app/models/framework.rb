class Framework < ApplicationRecord
  has_many :frameworks_frameworks, :foreign_key => 'framework_id', :class_name => 'FrameworkFramework'
  has_many :frameworks, :through => :frameworks_frameworks, :source => :other_framework

  has_many :frameworks_taxonomies, :class_name => 'FrameworkTaxonomy', inverse_of: :framework, dependent: :destroy
  has_many :taxonomies, through: :frameworks_taxonomies

  has_many :recommendations

  validates :title, presence: true
end
