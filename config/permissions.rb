# config/permissions.rb
module Permissions
  ROLE_HIERARCHY = {
    "admin" => 3,
    "manager" => 2,
    "contributor" => 1
  }.freeze

  def self.allowed_for(model, action)
    result = DEFINITIONS.dig(model.to_s, action.to_s) ||
             DEFINITIONS.dig('application', action.to_s)

    # Return the result as-is if it's true/false (for special permissions like update_self)
    return result if result == true || result == false

    # Otherwise return array (empty if nil)
    result || []
  end

  def self.roles_with_permission(model, action)
    allowed = allowed_for(model, action)

    # If true, return all roles (everyone has permission)
    return ROLE_HIERARCHY.keys if allowed == true

    # If false or empty array, no one has permission
    return [] if allowed == false || allowed.empty?

    # Expand hierarchical roles
    allowed.flat_map do |role|
      if ROLE_HIERARCHY.key?(role)
        # Get all roles at this level or above
        ROLE_HIERARCHY.select { |r, level| level >= ROLE_HIERARCHY[role] }.keys
      else
        # Non-hierarchical role, return as-is
        [role]
      end
    end.uniq
  end

  DEFINITIONS = {
    "application" => {
      "create" => ["manager"],
      "update" => ["manager"],
      "update_archived" => ["admin"],
      "destroy" => ["manager"],
      "modify_is_archive" => ["admin"],
      "modify_draft" => ["manager"],
      "view_archived" => ["manager"],
      "view_draft" => ["manager"]
    },

    "category" => {
      # "create" => ["manager"],
      # "update" => ["manager"],
      "destroy" => [], # Disabled
      "modify_manager_id" => ["admin"],  # Only admins can change manager after creation
      "assign_as_responsible" => ["admin"]
    },

    "due_date" => {
      # create/update/destroy blocked in policy - due dates are auto-generated
      "show" => ["manager"],
      "view_all" => ["manager"]
    },

    "indicator" => {
      # 'create' => [], # disabled feature
      # 'update' => ['manager'],
      "destroy" => [],  # Disabled
      "assign_as_responsible" => ["manager"]
    },

    "measure" => {
      # 'create' => [], # disabled feature
      # 'update' => ['manager'],
      "destroy" => []  # Disabled
    },

    "page" => {
      "create" => ["admin"],
      "modify_draft" => ["admin"],
      # "update" => ["manager"],
      "destroy" => []  # Disabled
    },

    "progress_report" => {
      # 'create' => [], # disabled feature
      # 'update' => ['manager'],
      "modify_draft" => ["manager"],
      "create_own_draft" => ["manager"], # managers can create their own
      "update_own_draft" => ["manager"]  # managers can update their own drafts
      # 'destroy' => [], # blocked in policy
    },

    "recommendation" => {
      # 'create' => ['manager'],
      # 'update' => ['manager'],
      "destroy" => []  # Disabled
    },

    "user" => {
      # 'create' => [], blocked in policy
      "update_self" => true, # true = everyone, false/[] = disabled, ['role'] = specific roles
      "update_lower" => ["admin"],
      # 'destroy' => [], blocked in policy
      "show_email" => ["admin"],
      "view_all" => ["manager"]  # managers+ can see all users
    },

    "user_role" => {
      "create_any" => ["admin"],
      "create_lower" => ["admin"],
      "destroy_any" => ["admin"],
      "destroy_lower" => ["admin"],
      "view_all" => ["manager"] # managers+ can see content
    }
  }.freeze
end
