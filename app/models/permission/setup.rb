class Permission
  class Setup
    def self.call(**args)
      new.call(**args)
    end

    def call(intended_environment:)
      if intended_environment != Rails.env || Rails.env.nil?
        raise "You must specify the intended environment to run this setup script. This is to prevent accidental execution in sensitive environments like production."
      end

      Permission::Config.resources.flat_map do |resource|
        Permission::Config.operations.flat_map do |operation|
          Permission::Config.status_options.flat_map do |status|
            organisation_only = Permission::Config.organisation_only_resources.include?(resource)
            publicly_allowed = Permission::Config.public_operations.dig(resource, operation)&.include?(status)
            user_only = Permission::Config.user_only_resources.include?(resource)

            permission = Permission.find_or_create_by!(
              operation: operation,
              resource: resource,
              status: status,
              organisation_only_at: organisation_only ? DateTime.now : nil,
              publicly_allowed_at: publicly_allowed ? DateTime.now : nil,
              user_only_at: user_only ? DateTime.now : nil
            )

            permission
          end
        end
      end
    end
  end
end
