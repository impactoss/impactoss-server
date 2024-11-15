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

  class Scope
    attr_reader :user, :scope

    def resolve
      filter_draft(filter_archived(scope))
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    private

    def filter_archived(query)
      return query if query.column_names.exclude?("is_archive")

      if operation_allowed?("read", ["archived"])
        query
      else
        query.where(is_archive: false)
      end
    end

    def filter_draft(query)
      return query if query.column_names.exclude?("draft")

      if operation_allowed?("read", ["draft"])
        query
      else
        query.where(draft: false)
      end
    end

    def filter_user_only(query)
      return query if .column_names.exclude?("user_only")

      if operation_allowed?("read", ["user_only"])
        query
      else
        query.where(user_only: false)
      end
    end

    def operation_allowed?(operation, statuses)
      Permission.allowed?(
        user: user,
        operation: operation,
        resource: scope.model_name.singular.underscore,
        statuses: statuses
      )
    end
  end

  def operation_allowed?(operation, statuses = ["active"])
    Permission.allowed?(
      user: @user,
      operation: operation,
      resource: resource,
      statuses: statuses
    )
  end

  def resource
    self.class.to_s.gsub("Policy", "").underscore
  end
end
