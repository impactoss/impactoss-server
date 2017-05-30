# frozen_string_literal: true
class SdgtargetMeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [:sdgtarget_id,
     :measure_id]
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
