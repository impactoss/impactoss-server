class RolePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
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

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def permitted_attributes
    []
  end
end
