class SdgtargetCategorySerializer
  include FastApplicationSerializer

  attributes :sdgtarget_id, :category_id

  set_type :sdgtarget_categories
end
