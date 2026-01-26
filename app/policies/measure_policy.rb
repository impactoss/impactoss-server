# frozen_string_literal: true

class MeasurePolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :description,
      :draft,
      :indicator_summary,
      :outcome,
      :reference,
      :target_date_comment,
      :target_date,
      :title
    ]

    attrs << :is_archive if @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs.compact
  end
end
