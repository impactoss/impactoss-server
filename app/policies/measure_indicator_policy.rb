# frozen_string_literal: true

class MeasureIndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [:measure_id,
      :indicator_id,
      measure_attributes: [:id, :title, :description, :target_date, :draft],
      indicator_attributes: [:id, :title, :description, :draft]]
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
