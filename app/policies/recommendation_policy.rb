# frozen_string_literal: true
class RecommendationPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    @user.role?('admin') || @user.role?('manager')
  end

  def edit?
    @user.role?('admin') || @user.role?('manager')
  end

  def update?
    @user.role?('admin') || @user.role?('manager')
  end

  def destroy?
    false
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
