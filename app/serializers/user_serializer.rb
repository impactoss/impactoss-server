class UserSerializer
  include FastApplicationSerializer

  attributes :email, :name

  set_type :users
end
