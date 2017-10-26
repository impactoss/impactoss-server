# frozen_string_literal: true
class ProgressReportPolicy < ApplicationPolicy
  def permitted_attributes
    [:indicator_id, :due_date_id, :title, :description, :document_url, :document_public, :draft,
     indicator_attributes: [:id, :title, :description, :draft],
     due_date_attributes: [:id, :due_date, :indicator_id, :draft]]
  end

  def create?
    @user # super || (@user.role?('contributor') && @record.manager == @user)
  end

  def update?
    super || (@user.role?('contributor') && @record.manager == @user)
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?('admin') || @user.role?('manager') || @user.role?('contributor')
      scope.where(draft: false)
    end
  end
end
