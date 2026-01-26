# frozen_string_literal: true

class IndicatorPolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :description,
      :draft,
      :end_date,
      :frequency_months,
      :manager_id,
      :reference,
      :repeat,
      :start_date,
      :title
    ]

    attrs << :is_archive if @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs.compact
  end
end
