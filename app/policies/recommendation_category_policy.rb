# frozen_string_literal: true

class RecommendationCategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:recommendation_id,
      :category_id,
      recommendation_attributes: [:id, :title, :number, :draft],
      category_attributes: [:id, :title, :short_title, :description, :url,
        :taxonomy_id,
        :draft,
        :manager_id]]
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
