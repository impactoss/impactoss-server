# frozen_string_literal: true

class IndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :description,
      :draft,
      :end_date,
      :frequency_months,
      :manager_id,
      :reference,
      :repeat,
      :start_date,
      :title,
      (:is_archive if @user.role?("admin")),
      measure_indicators_attributes: [
        :measure_id,
        measure_attributes: [:id, :title, :description, :target_date, :draft]
      ]
    ].compact
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
      scope.where(draft: false)
    end
  end
end
