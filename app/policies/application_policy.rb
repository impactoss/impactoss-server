class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    true
  end

  def create?
    @user.has_any_role?(allowed_roles_for(:create))
  end

  def update?
    return false unless @user.has_any_role?(allowed_roles_for(:update))

    # For archived records, check additional permission
    if @record.try(:is_archive)
      return @user.has_any_role?(allowed_roles_for(:update_archived))
    end

    true
  end

  def show?
    true
  end

  def destroy?
    allowed = allowed_roles_for(:destroy)
    return false if allowed.empty?
    @user.has_any_role?(allowed)
  end

  private

  def allowed_roles_for(action)
    policy_key = self.class.name.underscore.gsub('_policy', '')
    Permissions.allowed_for(policy_key, action)
  end

  class Scope
    attr_reader :user, :scope

    def resolve
      query = scope

      # Filter archived content if model has is_archive
      if scope.column_names.include?('is_archive')
        unless @user.has_any_role?(allowed_roles_for_scope(:view_archived))
          query = query.where(is_archive: false)
        end
      end

      # Filter draft content if model has draft
      if scope.column_names.include?('draft')
        unless @user.has_any_role?(allowed_roles_for_scope(:view_draft))
          query = query.where(draft: false)
        end
      end

      query
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    private

    def allowed_roles_for_scope(action)
      policy_key = @scope.model_name.singular
      Permissions.allowed_for(policy_key, action)
    end
  end
end
