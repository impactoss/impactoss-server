# frozen_string_literal: true

class UserRolePolicy < ApplicationPolicy
  def update?
    false
  end

  def create?
    # Admins can assign any role
    return true if @user.has_any_role?(allowed_roles_for(:create_any))

    # Managers can assign roles lower than themselves
    @user.has_any_role?(allowed_roles_for(:create_lower)) &&
      can_update_lower_role? &&
      !target_user_has_equal_or_higher_role?
  end

  def destroy?
    # Admins can remove any role
    return true if @user.has_any_role?(allowed_roles_for(:destroy_any))

    # Managers can remove roles lower than themselves
    @user.has_any_role?(allowed_roles_for(:destroy_lower)) &&
      can_update_lower_role? &&
      !target_user_has_equal_or_higher_role?
  end

  def permitted_attributes
    [:user_id, :role_id]
  end

  private

  def can_update_lower_role?
    target_role_level = Permissions::ROLE_HIERARCHY[@record.role_name]
    return false unless target_role_level

    # Manager can only assign roles with lower hierarchy level
    @user.roles.any? do |user_role|
      user_level = Permissions::ROLE_HIERARCHY[user_role.name]
      user_level && user_level > target_role_level
    end
  end

  def target_user_has_equal_or_higher_role?
    # Get the current user's highest role level
    current_user_max_level = @user.roles.map { |r| Permissions::ROLE_HIERARCHY[r.name] }.compact.max
    return false unless current_user_max_level

    # Check if target user has any role at same level or higher than current user
    @record.user.roles.any? do |user_role|
      user_level = Permissions::ROLE_HIERARCHY[user_role.name]
      user_level && user_level >= current_user_max_level
    end
  end

  class Scope < Scope
    def resolve
      if @user.has_any_role?(allowed_roles_for_scope(:view_all))
        scope.all
      else
        scope.where(user_id: @user.id)
      end
    end
  end
end
