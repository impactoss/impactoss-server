# frozen_string_literal: true

class MeasurePolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :description,
      :indicator_summary,
      :outcome,
      :reference,
      :target_date_comment,
      :target_date,
      :title
    ]

    attrs << :is_archive if !@record.new_record? && @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs << :draft if @user.has_any_role?(allowed_roles_for(:modify_draft))

    attrs.compact
  end
end
