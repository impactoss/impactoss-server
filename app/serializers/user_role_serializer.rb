class UserRoleSerializer
  include FastVersionedSerializer

  attributes :user_id, :role_id

  set_type :user_roles
end
