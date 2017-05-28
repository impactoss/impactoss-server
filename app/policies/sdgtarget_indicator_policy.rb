# frozen_string_literal: true
class SdgtargetIndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [:sdgtarget_id,
     :indicator_id]
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
