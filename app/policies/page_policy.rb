class PagePolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :content,
      :menu_title,
      :order,
      :title
    ]

    attrs << :is_archive if !@record.new_record? && @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs << :draft if @user.has_any_role?(allowed_roles_for(:modify_draft))

    attrs.compact
  end
end
