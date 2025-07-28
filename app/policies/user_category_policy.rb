# frozen_string_literal: true

class UserCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:user_id, :category_id]
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
