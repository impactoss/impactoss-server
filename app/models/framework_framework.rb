class FrameworkFramework < ApplicationRecord
  belongs_to :framework, :foreign_key => "framework_id", :class_name => "Framework"
  belongs_to :other_framework, :foreign_key => "other_framework_id", :class_name => "Framework"
end
