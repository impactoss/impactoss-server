# frozen_string_literal: true
class DueDatePolicy < ApplicationPolicy
  def permitted_attributes
    [:due_date,
     :indicator_id,
     :draft,
     measure_indicators_attributes: [:measure_id,
                                     measure_attributes: [:id, :title, :description, :target_date, :draft]]]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager')
      scope.where(draft: false)
    end
  end
end
