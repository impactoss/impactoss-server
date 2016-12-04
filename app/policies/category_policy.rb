# frozen_string_literal: true
class CategoryPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    @user.present?
  end

  def create?
    @user.present?
  end

  def new?
    @user.present? # TODO: fix
  end

  def destroy?
    false
  end

  def permitted_attributes
    [:title]
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
