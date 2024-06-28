# frozen_string_literal: true

class MeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [
      :description,
      :draft,
      :indicator_summary,
      :outcome,
      :reference,
      :target_date_comment,
      :target_date,
      :title,
      (:is_archive if @user.role?("admin")),
      recommendation_measures_attributes: [
        :recommendation_id,
        recommendation_attributes: [:id, :title, :number, :draft]
      ],
      measure_categories_attributes: [
        :category_id,
        category_attributes: [
          :description,
          :draft,
          :id,
          :manager_id,
          :short_title,
          :taxonomy_id,
          :title,
          :url
        ]
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
