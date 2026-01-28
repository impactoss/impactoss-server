class RolePolicy < ApplicationPolicy
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
