# frozen_string_literal: true
class UserRolePolicy < ApplicationPolicy
  def index?
    @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
  end

  def show?
    @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
  end

  def update?
    false
  end

  def create?
    return true if @user.role?('admin')
    return true if @user.role?('manager') && (@record.role_name == 'manager' || @record.role_name == 'contributor')
    @user.role?('contributor') && @record.role_name == 'contributor'
  end

  def destroy?
    return true if @user.role?('admin')
    @user.role?('manager') && @record.role_name == 'contributor'
  end

  def permitted_attributes
    [:user_id,
     :role_id,
     user_attributes: [:id],
     role_attributes: [:id]]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin')
      return scope.joins(:role).merge(Role.where(name: 'manager').or(Role.where(name: 'contributor'))) if @user.role?('manager')
      return scope.joins(:role).merge(Role.where(name: 'contributor')) if @user.role?('contributor')
      scope.none
    end
  end
end
