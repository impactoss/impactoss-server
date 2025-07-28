# frozen_string_literal: true

class MeasureCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:measure_id, :category_id]
  end

  def update?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
