class FrameworkTaxonomy < ApplicationRecord
  self.table_name = "frameworks_taxonomies"

  belongs_to :framework
  belongs_to :taxonomy
end
