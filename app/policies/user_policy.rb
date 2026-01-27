class UserPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
    # Check self-update permission
    if @record.id == @user.id
      update_self_permission = Permissions.allowed_for('user', 'update_self')

      # If true, anyone can update themselves
      return true if update_self_permission == true
      
      # If false or empty array, disabled
      return false if update_self_permission == false || update_self_permission.nil? || update_self_permission.empty?

      # If array of roles, check if user has required role
      return @user.has_any_role?(update_self_permission) if update_self_permission.is_a?(Array)
    end

    # Admins can update anyone
    return true if @user.has_any_role?(allowed_roles_for(:update_any))

    # Managers can update lower-level users (contributors, guests)
    if @user.has_any_role?(allowed_roles_for(:update_lower))
      user_max_level = @user.roles.map { |r| Permissions::ROLE_HIERARCHY[r.name] }.compact.max || 0
      record_max_level = @record.roles.map { |r| Permissions::ROLE_HIERARCHY[r.name] }.compact.max || 0
      return user_max_level > record_max_level
    end

    false
  end

  def destroy?
    false
  end

  def permitted_attributes
    [:email, :password, :password_confirmation, :name]
  end

  def show_email?
    own_record? || @user.has_any_role?(allowed_roles_for(:show_email))
  end

  private

  def own_record?
    @record.id == @user.id
  end

  class Scope < Scope
    def resolve
      if @user.has_any_role?(allowed_roles_for_scope(:view_all))
        scope.all
      else
        scope.where(id: @user.id)
      end
    end

    private

    def allowed_roles_for_scope(action)
      policy_key = @scope.model_name.singular
      Permissions.allowed_for(policy_key, action)
    end
  end
end
