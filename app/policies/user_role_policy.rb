# frozen_string_literal: true
class UserRolePolicy < ApplicationPolicy
  def permitted_attributes
    [:user_id,
     :role_id,
     user_attributes: [:id],
     role_attributes: [:id]]
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
