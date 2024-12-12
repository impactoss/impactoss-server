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
    false
  end

  def destroy?
    false
  end

  def permitted_attributes
    [:email, :password, :password_confirmation, :name]
  end

  def show_email?
    @user.role?("admin") || @record.id == @user.id
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager")

      scope.where(id: @user.id)
    end
  end
end
