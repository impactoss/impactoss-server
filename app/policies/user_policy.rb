class UserPolicy < ApplicationPolicy
  def index?
    @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
  end

  def create?
    false
  end

  def edit?
    false
  end

  def update?
    @record.id == @user.id || @user.role?('admin')
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
      return scope.all if @user.role?('admin')
      return scope.joins(:roles).where('user_id = ? OR roles.name = ?', @user.id, 'contributor') if @user.role?('manager')
      scope.where(id: @user.id)
    end
  end
end
