# frozen_string_literal: true

class FrameworkTaxonomyPolicy < ApplicationPolicy
  def update?
    false
  end

  def create?
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
