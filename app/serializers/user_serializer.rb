class UserSerializer
  include FastVersionedSerializer

  attributes :email, :name

  set_type :users
end
