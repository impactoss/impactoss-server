# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :date,
      :description,
      :draft,
      (:manager_id unless @record.persisted? && !@user.role?("admin")),
      :order,
      :parent_id,
      :reference,
      :short_title,
      :taxonomy_id,
      :title,
      :url,
      :user_only
    ].compact
  end

  def destroy?
    false
  end

  def create?
    @user.role?("admin")
  end

  def update?
    @user.role?("admin")
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
      scope.where(draft: false)
    end
  end
end
