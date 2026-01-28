require_relative "fast_application_serializer"

module FastVersionedSerializer
  def self.included(base)
    base.include FastApplicationSerializer

    base.attribute :created_by_id
    base.attribute :updated_by_id
  end

  def current_user_has_permission?
    current_user&.role?("admin") || current_user&.role?("manager")
  end
end
