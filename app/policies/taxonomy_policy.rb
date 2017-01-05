# frozen_string_literal: true
class TaxonomyPolicy < ApplicationPolicy
  def permitted_attributes
    [:title, :tags_recommendations, :tags_measures]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager')
      scope.where(draft: false)
    end
  end
end
