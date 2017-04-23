# frozen_string_literal: true
class UserRolePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
  end

  def update?
    false
  end

  def create?
    return true if @user.role?('admin')
    @user.role?('manager') && @record.role_name == 'contributor' && !(@record.user.role?('admin') || @record.user.role?('manager'))
  end

  def destroy?
    return true if @user.role?('admin')
    @user.role?('manager') && @record.role_name == 'contributor' && !(@record.user.role?('admin') || @record.user.role?('manager'))
  end

  def permitted_attributes
    [:user_id,
     :role_id,
     user_attributes: [:id],
     role_attributes: [:id]]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.where(user_id: @user.id)
    end
  end
end
