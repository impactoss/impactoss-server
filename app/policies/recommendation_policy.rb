class RecommendationPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    @user.role?("admin") || @user.role?("manager")
  end

  def edit?
    @user.role?("admin") || @user.role?("manager")
  end

  def update?
    @user.role?("admin") || @user.role?("manager")
  end

  def destroy?
    false
  end
end
