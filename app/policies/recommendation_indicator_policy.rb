# frozen_string_literal: true

class RecommendationIndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [:recommendation_id, :indicator_id]
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
