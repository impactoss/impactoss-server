class Permission < VersionedRecord
  def self.permission_operations
    %w[permission_grant permission_revoke]
  end

  def self.read_operations
    %w[read]
  end

  def self.write_operations
    %w[create destroy update]
  end

  def self.operations
    Permission.read_operations + Permission.write_operations + Permission.permission_operations
  end

  def self.resources
    %w[
      bookmark
      category
      due_date
      framework_framework
      framework_taxonomy
      indicator
      measure_category
      measure_indicator
      measure
      page
      progress_report
      recommendation_category
      recommendation_indicator
      recommendation_measure
      recommendation_recommendation
      recommendation
      role
      sdgtarget_category
      sdgtarget_indicator
      sdgtarget_measure
      sdgtarget_recommendation
      sdgtarget
      taxonomy
      user_category
      user_role
      user
    ]
  end

  def self.status_options
    %w[active archived draft]
  end

  has_many :role_permissions
  has_many :roles, through: :role_permissions

  validates :operation, presence: true, inclusion: {in: Permission.operations}
  validates :resource, presence: true, inclusion: {in: Permission.resources}
  validates :status, presence: true, inclusion: {in: Permission.status_options}

  def self.allowed?(operation:, resource:, user:, statuses: ["active"])
    permissions = where(operation: operation, resource: resource, status: statuses)

    missing_statuses = statuses - permissions.pluck(:status)

    if missing_statuses.any?
      raise Pundit::NotAuthorizedError,
        "#{"Permission".pluralize(missing_statuses.size)} not found for operation '#{operation}', resource '#{resource}', and #{"status".pluralize(missing_statuses.size)} '#{missing_statuses.join(", ")}'"
    end

    return true if permissions.all?(&:publicly_allowed?)

    permissions.all? do |permission|
      permission.allow?(user: user)
    end
  end

  def self.grant(operations:, resources:, roles:, statuses:, granting_user: nil, force: false)
    permissions = where(operation: operations, resource: resources, status: statuses)

    result = {
      granted: [],
      not_granted: []
    }

    roles.flat_map do |role|
      permissions.flat_map do |permission|
        if force || permission.can_grant?(user: granting_user)
          role_permission = RolePermission.find_or_create_by(permission: permission, role: role)

          if role_permission.revoked_at.present?
            role_permission.update(revoked_at: nil, updated_by: granting_user)
            role_permission.reload
          end

          result[:granted] << role_permission
        else
          result[:not_granted] << {
            permission: permission,
            role: role
          }
        end
      end
    end
  end

  def self.revoke(roles:, operations:, resources:, statuses:, revoking_user: nil, force: false)
    permissions = where(operation: operations, resource: resources, status: statuses)

    roles.flat_map do |role|
      permissions.flat_map do |permission|
        role_permission = RolePermission.find_by(permission: permission, role: role)

        if force || permission.can_revoke?(user: revoking_user)
          warn "Permission #{permission.id} forcibly granted to role #{role.name} (#{role.id}): #{permission.title}" if force

          if role_permission.present?
            role_permission.update(revoked_at: Time.now, updated_by: revoking_user)
            role_permission.reload

            result[:revoked] << role_permission
          else
            result[:not_revoked] << {
              permission: permission,
              role: role,
              reason: :not_found
            }
          end
        else
          result[:not_revoked] << {
            permission: permission,
            role: role,
            reason: :revoking_permission_denied
          }
        end
      end
    end
  end

  def allow?(user:)
    role_permissions.active.find_by(role: user.role_ids).present?
  end

  def can_grant?(user:)
    Permission.allowed?(operation: "permission_grant", resource: resource, statuses: [status], user: user)
  end

  def can_revoke?(user:)
    Permission.allowed?(operation: "permission_revoke", resource: resource, statuses: [status], user: user)
  end

  def description
    "Permission to #{operation} a #{resource} with the #{status} status"
  end

  def publicly_allowed?
    publicly_allowed_at.present?
  end

  def title
    "#{resource} #{operation}: #{status}".titleize
  end
end
