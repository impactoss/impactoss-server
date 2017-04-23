class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    false
  end

  def edit?
    false
  end

  def update?
    return true if @record.id == @user.id
    return true if @user.role?('admin')
    @user.role?('manager') && !(@record.role?('admin') || @record.role?('manager'))
  end

  def destroy?
    return true if @user.role?('admin')
    @record == @user
  end

  def permitted_attributes
    [:email, :password, :password_confirmation, :name]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.where(id: @user.id)
    end
  end
end
