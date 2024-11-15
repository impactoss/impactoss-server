class RolePermission
  class Config
    # Format: {
    #  "role name" => {
    #     "operations" => ["operation name"],
    #     "resources" => ["resource name"],
    #     "statuses" => ["status name"]
    #     }
    #   }
    # }
    def self.base_permissions_by_role
      {
        "admin" => {
          "operations" => Permission::Config.permission_operations +
            Permission::Config.read_operations +
            Permission::Config.write_operations,
          "resources" => Permission::Config.resources,
          "statuses" => Permission::Config.status_options
        },
        "contributor" => {
          "operations" => Permission::Config.read_operations,
          "resources" => Permission::Config.shared_resources,
          "statuses" => Permission::Config.status_options
        },
        "manager" => {
          "operations" => Permission::Config.read_operations +
            Permission::Config.write_operations,
          "resources" => Permission::Config.shared_resources,
          "statuses" => Permission::Config.status_options
        }
      }
    end

    # Format: {
    #   "role name" => {
    #     "resource name" (or "all_resources") => {
    #       "allowed" => {
    #         ["status options"] => ["operation name"]
    #       },
    #       "revoked" => {
    #         ["status options"] => ["operation name"]
    #       }
    #     }
    #   }
    # }
    def self.specific_permissions_by_role
      {
        "manager" => {
          "all_resources" => {
            "revoked" => {
              ["archived"] => ["update", "destroy"]
            }
          }
        }
      }
    end

    def self.admin_resources
      Permission::Config.resources
    end

    def self.contributor_operations
      Permission::Config.read_operations
    end

    def self.contributor_resources
      Permission::Config.shared_resources
    end

    def self.manager_operations
      Permission::Config.read_operations +
        Permission::Config.write_operations
    end

    def self.manager_resources
      Permission::Config.shared_resources
    end
  end
end
