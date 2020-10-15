class FrameworkFramework < ApplicationRecord
  self.table_name = "frameworks_frameworks"

  belongs_to :framework, class_name: 'Framework'
  belongs_to :other_framework, class_name: 'Framework'
end
