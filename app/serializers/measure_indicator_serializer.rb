class MeasureIndicatorSerializer
  include FastVersionedSerializer

  attributes :measure_id, :indicator_id

  set_type :measure_indicators
end
