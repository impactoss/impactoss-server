class SdgtargetSerializer
  include FastApplicationSerializer

  attributes :title, :description, :reference, :draft

  set_type :sdgtargets
end
