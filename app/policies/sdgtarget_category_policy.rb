# frozen_string_literal: true
class SdgtargetCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:sdgtarget_id,
     :category_id]
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
