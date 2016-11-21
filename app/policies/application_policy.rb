class ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user   = user
    @record = record
  end

  def show?
    false
  end

  def edit?
    false
  end

  def update?
    false
  end

  class Scope
    attr_reader :user, :scope
    def resolve
      scope.all if user && user.role?('admin')
    end

    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end
end
