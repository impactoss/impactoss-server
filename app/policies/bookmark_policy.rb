class BookmarkPolicy < ApplicationPolicy
  # def index?
  #   true
  # end

  # def create?
  #   true
  # end

  # def edit?
  #   true
  # end

  # def update?
  #   true
  # end

  # def destroy?
  #   true
  # end

  def permitted_attributes
    [:user_id, :title, :view]
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id).order(created_at: :desc)
    end
  end
end
