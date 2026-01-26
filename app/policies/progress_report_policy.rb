# frozen_string_literal: true

class ProgressReportPolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :indicator_id,
      :due_date_id,
      :title,
      :description,
      :document_url,
      :document_public,
      :draft
    ]

    attrs << :is_archive if @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs.compact
  end

  def create?
    return true if @user.has_any_role?(allowed_roles_for(:create))

    # Contributors can create their own draft reports
    @user.has_any_role?(allowed_roles_for(:create_own)) &&
      @record.draft? &&
      @record.manager == @user
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
