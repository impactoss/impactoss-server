# frozen_string_literal: true
class DueDatePolicy < ApplicationPolicy
  def permitted_attributes
    [:due_date,
     :indicator_id,
     :draft,
     measure_indicators_attributes: [:measure_id,
                                     measure_attributes: [:id, :title, :description, :target_date, :draft]]]
  end

  def show?
    super || @user.role?('contributor')
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.none
    end
  end
end
