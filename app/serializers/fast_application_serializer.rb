require 'fast_jsonapi'

module FastApplicationSerializer
  def self.included(base)
    base.include FastJsonapi::ObjectSerializer

    base.attribute :last_modified_user_id#, if: :current_user_has_permission?
    base.attribute :created_at do |object|
      object.created_at.in_time_zone.iso8601 if object.created_at
    end

    base.attribute :updated_at do |object|
      object.updated_at.in_time_zone.iso8601 if object.created_at
    end
  end

  def current_user_has_permission?
    current_user && (current_user.role?('admin') || current_user.role?('manager'))
  end
end
