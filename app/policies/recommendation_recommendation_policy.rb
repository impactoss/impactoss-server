# frozen_string_literal: true
class RecommendationRecommendationPolicy < ApplicationPolicy
    def permitted_attributes
      [:recommendation_id,
       :other_recommendation_id]
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