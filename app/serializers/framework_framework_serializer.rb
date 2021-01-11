class FrameworkFrameworkSerializer
    include FastApplicationSerializer
  
    attributes :framework_id, :other_framework_id
  
    set_type :framework_frameworks
  end