# frozen_string_literal: true
class MeasureCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:measure_id,
     :category_id,
     measure_attributes: [:title, :description, :target_date, :draft],
     category_attributes: [:id, :title, :short_title, :description, :url,
                           :taxonomy_id,
                           :draft,
                           :manager_id]]
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
