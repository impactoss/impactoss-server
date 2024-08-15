class CategorySerializer
  include FastVersionedSerializer
  attributes :title,
    :parent_id,
    :short_title,
    :description,
    :url,
    :draft,
    :reference,
    :taxonomy_id,
    :manager_id,
    :date,
    :user_only,
    :is_archive,
    :is_current

  set_type :categories
end
