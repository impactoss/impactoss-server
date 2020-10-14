class Framework < ApplicationRecord
  has_many :children, class_name: 'Framework', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Framework', optional: true

  has_many :taxonomies
end
