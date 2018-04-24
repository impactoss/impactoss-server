class UserRoleSerializer
  include FastApplicationSerializer

  attributes :user_id, :role_id

  set_type :user_roles
end
