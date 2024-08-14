# frozen_string_literal: true

class RecommendationPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :title,
      :draft,
      :accepted,
      :response,
      :reference,
      :description,
      :framework_id,
      :support_level,
      (:is_archive if @user.role?("admin")),
      recommendation_categories_attributes: [:category_id]
    ]
  end

  def destroy?
    false
  end

  def update?
    super && (@user.role?("admin") || !@record.is_archive?)
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
      scope.where(draft: false)
    end
  end
end
