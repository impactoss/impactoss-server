class PagePolicy < ApplicationPolicy
  def permitted_attributes
    attrs = [
      :content,
      :draft,
      :menu_title,
      :order,
      :title
    ]

    attrs << :is_archive if @user.has_any_role?(allowed_roles_for(:modify_is_archive))
    attrs.compact
  end
end
