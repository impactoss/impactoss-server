# frozen_string_literal: true

class MeasureIndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [:measure_id, :indicator_id]
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
