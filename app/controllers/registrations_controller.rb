# frozen_string_literal: true

##
# Custom registrations controller for devise-token-auth.
#
# Extends DeviseTokenAuth::RegistrationsController to skip
# ApplicationController callbacks that don't apply to registration actions.
class RegistrationsController < DeviseTokenAuth::RegistrationsController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false
end
