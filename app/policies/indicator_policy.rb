# frozen_string_literal: true
class IndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [:title,
     :description,
     :draft,
     :manager_id,
     :frequency_months,
     :start_date,
     :repeat,
     :end_date,     
     :reference,
     measure_indicators_attributes: [:measure_id,
                                     measure_attributes: [:id, :title, :description, :target_date, :draft]]]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.where(draft: false)
    end
  end
end
