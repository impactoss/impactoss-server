# frozen_string_literal: true
class SdgtargetRecommendationPolicy < ApplicationPolicy
  def permitted_attributes
    [:sdgtarget_id,
     :recommendation_id]
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
