class CategorySerializer
  include FastVersionedSerializer
  attributes :title, :categories, :parent_id, :short_title, :description, :url, :draft, :reference, :taxonomy_id, :manager_id, :date, :user_only

  set_type :categories
end
