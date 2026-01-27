# frozen_string_literal: true

class IndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :description,
      :end_date,
      :frequency_months,
      :manager_id,
      :reference,
      :repeat,
      :start_date,
      :title
    ]

    attrs << :is_archive if !@record.new_record? && @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs << :draft if @user.has_any_role?(allowed_roles_for(:modify_draft))

    attrs.compact
  end
end
