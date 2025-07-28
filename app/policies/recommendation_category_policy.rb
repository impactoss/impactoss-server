# frozen_string_literal: true

class RecommendationCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:recommendation_id, :category_id]
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
