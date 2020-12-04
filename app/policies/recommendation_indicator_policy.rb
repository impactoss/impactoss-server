# frozen_string_literal: true
class RecommendationIndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [:recommendation_id, :indicator_id]
  end

  # TODO pretty sure we don't actually need this now as I've excluded the route. But, consistency? Could remove from other policies and add `except: [:update]`` on their routes instead? 
  #   it's really weird how some controllers implement an update but the policy precludes the use of it... possibly I am missing something?
  def update?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
