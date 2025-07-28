# frozen_string_literal: true

class RecommendationMeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [:recommendation_id, :measure_id]
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
