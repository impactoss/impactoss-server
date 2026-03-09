# frozen_string_literal: true

class DueDatePolicy < ApplicationPolicy
  def permitted_attributes
    [:due_date, :indicator_id, :draft]
  end

  class Scope < Scope
    def resolve
      if @user.has_any_role?(allowed_roles_for_scope(:view_all))
        scope.all
      else
        scope.none  # Public can't see due dates
      end
    end
  end
end
