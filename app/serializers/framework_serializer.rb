class FrameworkSerializer
  include FastApplicationSerializer

  attributes :title, :short_title, :description, :has_indicators, :has_measures, :has_response, :parent_id

  set_type :frameworks
end
