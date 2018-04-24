class MeasureCategorySerializer
  include FastApplicationSerializer

  attributes :measure_id, :category_id

  set_type :measure_categories
end
