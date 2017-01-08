# frozen_string_literal: true
class RecommendationMeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [:recommendation_id,
     :measure_id,
     recommendation_attributes: [:id, :title, :number, :draft],
     measure_attributes: [:id, :title, :description, :target_date, :draft]]
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
