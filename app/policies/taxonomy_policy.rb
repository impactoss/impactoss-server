# frozen_string_literal: true
class TaxonomyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    @user.present?
  end

  def new?
    @user.present?
  end

  def destroy?
    false
  end

  def permitted_attributes
    [:title, :tags_recommendations, :tags_measures]
  end

  class Scope < Scope
    def resolve
      scope.all
      # Turn on the code below once we have organisation
      # scope.all if user.role?("admin")
      # scope.where(organisation_id: user.organisation.id)
    end
  end
end
