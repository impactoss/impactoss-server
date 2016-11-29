# frozen_string_literal: true
class IndicatorPolicy < ApplicationPolicy
  def index?
    @user.present?
  end

  def new?
    @user.role?('admin') || @user.role?('manager') || @user.role?('reporter')
  end

  def create?
    @user.role?('admin') || @user.role?('manager') || @user.role?('reporter')
  end

  def edit?
    @user.role?('admin') || @user.role?('manager') || @user.role?('reporter')
  end

  def update?
    @user.role?('admin') || @user.role?('manager') || @user.role?('reporter')
  end

  def show?
    @user.present?
  end

  def destroy?
    false
  end

  def permitted_attributes
    [:title, :description]
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
