# frozen_string_literal: true
class TaxonomyPolicy < ApplicationPolicy
  def permitted_attributes
    [:title, :tags_recommendations, :tags_measures, :allow_multiple, :tags_users, :tags_sdgtargets, :priority, :is_smart, :groups_measures_default, :groups_recommendations_default, :groups_sdgtargets_default]
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
