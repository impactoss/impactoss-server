# frozen_string_literal: true

class IndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :description,
      :draft,
      :end_date,
      :frequency_months,
      :manager_id,
      :reference,
      :repeat,
      :start_date,
      :title,
      (:is_archive if @user.role?("admin"))
    ].compact
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
      scope.where(draft: false, is_archive: false)
    end
  end
end
