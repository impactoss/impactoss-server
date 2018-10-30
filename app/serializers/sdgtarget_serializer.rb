class SdgtargetSerializer
  include FastVersionedSerializer

  attributes :title, :description, :reference, :draft

  set_type :sdgtargets
end
