# frozen_string_literal: true

class SdgtargetPolicy < ApplicationPolicy
  def permitted_attributes
    [:title, :description, :reference, :draft]
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
      scope.where(draft: false)
    end
  end
end
