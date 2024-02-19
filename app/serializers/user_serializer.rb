class UserSerializer
  include FastVersionedSerializer

  attributes :email,
    :name,
    :relationship_updated_at,
    :relationship_updated_by_id

  set_type :users
end
