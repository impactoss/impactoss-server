class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def create?
    operation_allowed?("create")
  end

  def destroy?
    operation_allowed?("destroy")
  end

  def index?
    operation_allowed?("read")
  end

  def show?
    operation_allowed?("read")
  end

  def update?
    operation_allowed?("update")
  end

  private

  def operation_allowed?(operation, statuses = ["active"])
    permissions = Permission.relevant(operation: operation, resource: resource, user: @user, statuses: statuses)

    permissions.all? do |permission|
      if permission.user_only? && @record.user_id != @user.id
        return false
      end

      if permission.organisation_only? && @record.organisations.where(id: @user.organisations).empty?
        return false
      end

      permission.allow?(user: @user)
    end
  end

  def shared_organisation?
    record.includes(:organisations).where(organisations: {id: user.organisations})
  end

  def resource
    self.class.to_s.gsub("Policy", "").underscore
  end

  class Scope
    attr_reader :user, :scope

    def resolve
      filter_archived(
        filter_draft(
          filter_organisation_only(
            filter_user_only(
              scope
            )
          )
        )
      )
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    private

    def permissions
      @permissions ||= Permission.where(
        operation: "read",
        resource: scope.model_name.singular.underscore
      )
    end

    def filter_archived(query)
      return query if query.column_names.exclude?("is_archive")

      if permissions.where(status: "archived").allow?(user: user)
        query
      else
        query.where(is_archive: false)
      end
    end

    def filter_draft(query)
      return query if query.column_names.exclude?("draft")

      if permissions.where(status: "draft").allow?(user: user)
        query
      else
        query.where(draft: false)
      end
    end

    def filter_organisation_only(query)
      if permissions.organisation_only.none?
        query
      else
        query.includes(:organisations).where(organisations: {id: user.organisations})
      end
    end

    def filter_user_only(query)
      if permissions.user_only.any?
        query
      else
        query.where(user: user)
      end
    end

    def scoped_operation_allowed?(operation, statuses)
      Permission.allowed?(
        operation: operation,
        resource: scope.model_name.singular.underscore,
        statuses: statuses,
        user: user
      )
    end
  end
end
