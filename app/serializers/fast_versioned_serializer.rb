require_relative 'fast_application_serializer'

module FastVersionedSerializer
  def self.included(base)
    base.include FastApplicationSerializer

    base.attribute :last_modified_user_id#, if: :current_user_has_permission?
  end

  def current_user_has_permission?
    current_user && (current_user.role?('admin') || current_user.role?('manager'))
  end
end
