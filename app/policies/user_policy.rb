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
    return true if @user.role?("admin")
    @user.role?("manager") && !(@record.role?("admin") || @record.role?("manager"))
  end

  def destroy?
    false
  end

  def permitted_attributes
    [
      :name,
      :password,
      :password_confirmation,
      (:email if @record.new_record?)
    ].compact
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
