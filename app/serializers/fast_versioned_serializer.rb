require_relative "fast_application_serializer"

module FastVersionedSerializer
  def self.included(base)
    base.include FastApplicationSerializer

    base.attribute :created_by_id # leftovers:keep
    base.attribute :updated_by_id # leftovers:keep
  end

  # This appears to be uncalled but I'm not 100% sure. Maybe we can delete it?
  def current_user_has_permission? # leftovers:keep
    current_user&.role?("admin") || current_user&.role?("manager")
  end
end
