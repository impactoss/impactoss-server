# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :date,
      :description,
      :order,
      :parent_id,
      :reference,
      :short_title,
      :taxonomy_id,
      :title,
      :url,
      :user_only
    ]

    # manager_id can be set on create, or on update by admins only
    attrs << :manager_id unless @record.persisted? && !@user.has_any_role?(allowed_roles_for(:modify_manager_id))

    attrs << :is_archive if !@record.new_record? && @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs << :draft if @user.has_any_role?(allowed_roles_for(:modify_draft))

    attrs.compact
  end

  # destroy?, create? and update? inherited from ApplicationPolicy
end
