class PagePolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    @user.role?("admin")
  end

  def edit?
    false
  end

  def update?
    @user.role?("admin")
  end

  def destroy?
    false
  end

  def permitted_attributes
    [
      :content,
      :draft,
      (:is_archive if @user.role?("admin")),
      :menu_title,
      :order,
      :title
    ].compact
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
      scope.where(draft: false, is_archive: false)
    end
  end
end
