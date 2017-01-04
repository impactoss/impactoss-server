# frozen_string_literal: true
class MeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [:title, :description, :target_date, :draft]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager')
      scope.where(draft: false)
    end
  end
end
