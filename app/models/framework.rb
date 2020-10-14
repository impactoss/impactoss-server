class Framework < ApplicationRecord
  has_many :children, class_name: 'Framework', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Framework', optional: true

  has_many :frameworks_taxonomies, :class_name => 'FrameworkTaxonomy', inverse_of: :framework, dependent: :destroy
  has_many :taxonomies, through: :frameworks_taxonomies

  has_many :recommendations
end
