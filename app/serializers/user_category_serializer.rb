class UserCategorySerializer
  include FastVersionedSerializer

  attributes :user_id, :category_id

  set_type :user_categories
end
