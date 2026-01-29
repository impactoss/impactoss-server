class UserSerializer
  include FastVersionedSerializer

  attributes :domain,
    :email,
    :name,
    :relationship_updated_at,
    :relationship_updated_by_id,
    :multi_factor_email_code_enabled,
    :otp_required_for_login

  set_type :users
end
