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
      scope.all if @user.role?("admin") || @user.role?("manager") || @user.role?("contributor")
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end

  private

  def operation_allowed?(operation)
    Permission.allowed?(user: @user, operation: operation, resource: resource)
  end

  def resource
    self.class.to_s.gsub("Policy", "").underscore
  end
end
