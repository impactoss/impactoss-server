# config/permissions.rb
module Permissions
  ROLE_HIERARCHY = {
    'admin' => 3,
    'manager' => 2,
    'contributor' => 1
  }.freeze

  def self.allowed_for(model, action)
    DEFINITIONS.dig(model.to_s, action.to_s) ||
      DEFINITIONS.dig('application', action.to_s) ||
      []
  end

  # def self.roles_with_permission(model, action)
  #   allowed = allowed_for(model, action)
  #   return [] if allowed.nil?
  #
  #   # Expand hierarchical roles
  #   allowed.flat_map do |role|
  #     if ROLE_HIERARCHY.key?(role)
  #       # Get all roles at this level or above
  #       ROLE_HIERARCHY.select { |r, level| level >= ROLE_HIERARCHY[role] }.keys
  #     else
  #       # Non-hierarchical role, return as-is
  #       [role]
  #     end
  #   end.uniq
  # end

  DEFINITIONS = {
    'application' => {
      'create' => ['manager'],
      'update' => ['manager'],
      'update_archived' => ['admin'],
      'destroy' => ['manager'],
      'modify_is_archive' => ['admin'],
      'view_archived' => ['contributor'],
      'view_draft' => ['contributor'],
      'view_all' => ['contributor'] # Contributors+ can see content
    },

    'category' => {
      'create' => ['admin'],
      'update' => ['admin'],
      'destroy' => [], # Disabled
      'modify_manager_id' => ['admin'],  # Only admins can change manager after creation
      'assign_as_responsible' => ['manager']
    },

    'due_date' => {
      # create/update/destroy blocked in policy - due dates are auto-generated
      'show' => ['contributor'],
      'view_all' => ['contributor']
    },

    'indicator' => {
      # 'create' => ['manager'],
      # 'update' => ['manager'],
      'destroy' => [],  # Disabled
      'assign_as_responsible' => ['contributor']
    },

    'measure' => {
      # 'create' => ['manager'],
      # 'update' => ['manager'],
      'destroy' => []  # Disabled
    },

    'page' => {
      'create' => ['admin'],
      'update' => ['admin'],
      'destroy' => []  # Disabled
    },

    'progress_report' => {
      # 'create' => ['manager'],
      # 'update' => ['manager'],
      'create_own' => ['contributor'],  # Contributors can create their own
      'update_own' => ['contributor']  # Contributors can update their own drafts
      # 'destroy' => [], # blocked in policy
    },

    'recommendation' => {
      # 'create' => ['manager'],
      # 'update' => ['manager'],
      'destroy' => []  # Disabled
    },

    'user' => {
      # 'create' => [], blocked in policy
      # 'update' => [], blocked in policy
      # 'destroy' => [], blocked in policy
      'show_email' => ['admin'],
      'view_all' => ['manager']  # Managers+ can see all users
    },

    'user_role' => {
      'create_any' => ['admin'],
      'create_lower' => ['manager'],
      'destroy_any' => ['admin'],
      'destroy_lower' => ['manager'],
      'show' => ['contributor']
    }
  }.freeze
end
