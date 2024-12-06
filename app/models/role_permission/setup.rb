class RolePermission
  class Setup
    def self.call(**args)
      new.call(**args)
    end

    def call(intended_environment:, force: false, granting_user: nil)
      if intended_environment != Rails.env || Rails.env.nil?
        raise "You must specify the intended environment to run this setup script. This is to prevent accidental execution in sensitive environments like production."
      end

      if !roles_ready?
        Role::Setup.call(intended_environment: intended_environment)
      end

      if !permissions_ready?
        Permission::Setup.call(intended_environment: intended_environment)
      end

      require "pry"

      RolePermission::Config.base_permissions_by_role.flat_map do |role_name, config|
        Permission.grant(
          force: force,
          granting_user: granting_user,
          operations: config["operations"],
          resources: config["resources"],
          roles: [roles_by_name[role_name]],
          statuses: Permission::Config.status_options
        )
      end
    end

    private

    def roles_by_name
      @roles_by_name ||= Role.all.index_by(&:name)
    end

    def permissions_ready?
      Permission.where(resource: Permission::Config.resources).count ==
        Permission::Config.resources.count *
          Permission::Config.operations.count *
          Permission::Config.status_options.count
    end

    def roles_ready?
      Role.where(name: RolePermission::Config.base_permissions_by_role.keys).count == RolePermission::Config.base_permissions_by_role.keys.count
    end
  end
end
