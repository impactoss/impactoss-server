class MeasureIndicatorSerializer
  include FastApplicationSerializer

  attributes :measure_id, :indicator_id

  set_type :measure_indicators
end
