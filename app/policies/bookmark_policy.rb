class BookmarkPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def permitted_attributes
    [:user_id, :title, :view]
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
