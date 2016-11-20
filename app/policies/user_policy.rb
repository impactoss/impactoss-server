class UserPolicy < ApplicationPolicy
  def index?
    @user.role? "admin"
  end

  def edit?
    @user.role? "admin"
  end

  def update?
    @user.role? "admin"
  end
end
