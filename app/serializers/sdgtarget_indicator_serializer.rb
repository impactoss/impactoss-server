class SdgtargetIndicatorSerializer
  include FastApplicationSerializer

  attributes :sdgtarget_id, :indicator_id

  set_type :sdgtarget_indicators
end
