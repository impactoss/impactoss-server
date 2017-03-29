class UserPolicy < ApplicationPolicy
  def index?
    @user.role? 'admin' || @user.role?('manager')
  end

  def create?
    false
  end

  def edit?
    @user.role? 'admin'
  end

  def update?
    @user.role? 'admin'
  end
end
