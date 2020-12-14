# frozen_string_literal: true
class FrameworkFrameworkPolicy < ApplicationPolicy
    def permitted_attributes
      [:framework_id,
       :other_framework_id]
    end
  
    def update?
      false
    end

    def create?
      false
    end

    def destroy?
      false
    end
  
    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end