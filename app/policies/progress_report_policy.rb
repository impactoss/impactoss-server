# frozen_string_literal: true

class ProgressReportPolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :indicator_id,
      :due_date_id,
      :title,
      :description,
      :document_url,
      :document_public
    ]

    attrs << :is_archive if !@record.new_record? && @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs << :draft if @user.has_any_role?(allowed_roles_for(:modify_draft))

    attrs.compact
  end

  def create?
    return true if @user.has_any_role?(allowed_roles_for(:create))

    # Contributors can create their own reports
    if @user.has_any_role?(allowed_roles_for(:create_own_draft)) &&
       @record.manager == @user

      # Must be draft unless they have modify_draft permission
      return false if !@record.draft? && !@user.has_any_role?(allowed_roles_for(:modify_draft))

      return true
    end

    false
  end

  def destroy?
    false
  end

  def update?
    # Can't update archived unless specifically allowed
    return false if @record.try(:is_archive) &&
      !@user.has_any_role?(allowed_roles_for(:update_archived))

    # Standard update permission
    return true if @user.has_any_role?(allowed_roles_for(:update))

    # Contributors can update their own draft reports (if draft status unchanged)
    @user.has_any_role?(allowed_roles_for(:update_own_draft)) &&
      @record.draft? &&
      !@record.draft_changed? &&
      @record.manager == @user

      # Can change draft status only if they have modify_draft permission
      return false if @record.draft_changed? && !@user.has_any_role?(allowed_roles_for(:modify_draft))
  end
end
