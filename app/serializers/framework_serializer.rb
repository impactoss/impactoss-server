class FrameworkSerializer
  include FastApplicationSerializer

  attributes :title, :short_title, :description, :has_indicators, :has_measures, :has_response

  set_type :frameworks
end
