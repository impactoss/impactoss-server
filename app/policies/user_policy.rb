class UserPolicy < ApplicationPolicy
  def edit?
    @user.role? "admin"
  end

  def update?
    @user.role? "admin"
  end
end
