class UserPolicy < ApplicationPolicy
  def create?
    false
  end

  def update?
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
