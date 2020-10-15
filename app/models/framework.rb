class Framework < ApplicationRecord
  has_many :frameworks_frameworks, :class_name => 'FrameworkFramework', inverse_of: :framework, dependent: :destroy
  has_many :frameworks, through: :frameworks_frameworks

  has_many :frameworks_taxonomies, :class_name => 'FrameworkTaxonomy', inverse_of: :framework, dependent: :destroy
  has_many :taxonomies, through: :frameworks_taxonomies

  has_many :recommendations
end
