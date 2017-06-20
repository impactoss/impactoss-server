# frozen_string_literal: true
class MeasurePolicy < ApplicationPolicy
  def permitted_attributes
    [:title, :description, :target_date, :draft, :outcome, :indicator_summary, :target_date_comment,
     recommendation_measures_attributes: [:recommendation_id,
                                          recommendation_attributes: [:id, :title, :number, :draft]],
     measure_categories_attributes: [:category_id,
                                     category_attributes: [:id, :title, :short_title, :description,
                                                           :url, :taxonomy_id, :draft,
                                                           :manager_id]]]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.where(draft: false)
    end
  end
end
