# frozen_string_literal: true

class ProgressReportPolicy < ApplicationPolicy
  def permitted_attributes
    [
      :indicator_id, :due_date_id, :title, :description, :document_url, :document_public, :draft,
      (:is_archive if @user.role?("admin")),
      indicator_attributes: [:id, :title, :description, :draft],
      due_date_attributes: [:id, :due_date, :indicator_id, :draft]
    ].compact
  end

  def create?
    return true if @user.role?("admin") || @user.role?("manager")

    @user.role?("contributor") && @record.draft? && @record.manager == @user
  end

  def destroy?
    false
  end

  def update?
    return false if @record.is_archive? && !@user.role?("admin")

    super || (@user.role?("contributor") && @record.draft? && !@record.draft_changed? && @record.manager == @user)
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
      scope.where(draft: false, is_archive: false)
    end
  end
end
