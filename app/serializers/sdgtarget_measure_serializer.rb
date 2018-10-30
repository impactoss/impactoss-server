class SdgtargetMeasureSerializer
  include FastApplicationSerializer

  attributes :sdgtarget_id, :measure_id

  set_type :sdgtarget_measures
end
