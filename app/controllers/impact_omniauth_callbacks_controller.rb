# frozen_string_literal: true

class ImpactOmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  def auth_hash
    @_auth_hash ||= request.env["omniauth.auth"] ||= session.delete("dta.omniauth.auth")
  end
end
