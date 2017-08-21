class ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at
  attribute :last_modified_user_id #, if: :current_user_has_permission?

  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.created_at
  end

  def current_user_has_permission?
    current_user && (current_user.role?('admin') || current_user.role?('manager'))
  end
end
