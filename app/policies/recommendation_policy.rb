# frozen_string_literal: true

class RecommendationPolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :title,
      :draft,
      :accepted,
      :response,
      :reference,
      :description,
      :framework_id,
      :support_level
    ]

    attrs << :is_archive if @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs.compact
  end

  # create?, update?, destroy? inherited from ApplicationPolicy
  # Scope inherited from ApplicationPolicy (handles draft/archive filtering)
end
