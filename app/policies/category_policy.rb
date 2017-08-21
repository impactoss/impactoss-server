# frozen_string_literal: true
class CategoryPolicy < ApplicationPolicy
  def permitted_attributes
    [:title, :short_title, :description, :url, :draft, :taxonomy_id, :manager_id, :order, :reference, :user_only]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.where(draft: false)
    end
  end
end
