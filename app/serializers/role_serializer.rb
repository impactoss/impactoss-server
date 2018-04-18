class RoleSerializer
  include FastApplicationSerializer

  attributes :name, :friendly_name

  set_type :roles
end
