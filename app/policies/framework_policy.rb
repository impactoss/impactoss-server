class FrameworkPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
