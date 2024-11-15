class Permission
  class Setup
    def self.call(**args)
      new.call(**args)
    end

    def call(intended_environment: nil)
      if !(Rails.env.development? || Rails.env.test?) || (
        intended_environment.present? &&
        intended_environment == Rails.env)
        raise "You can only run this in a development or test environment. You can bypass this restriction using the intended_environment argument."
      end

      Permission::Config.resources.flat_map do |resource|
        Permission::Config.operations.flat_map do |operation|
          Permission::Config.status_options.flat_map do |status|
            permission = Permission.find_or_create_by!(
              resource: resource,
              operation: operation,
              status: status,
              organization_only: Permission::Config.organization_only_resources.include?(resource),
              user_only: Permission::Config.user_only_resources.include?(resource)
            )

            if Permission::Config.public_operations.dig(resource, operation)&.include?(status)
              permission.update!(publicly_allowed_at: DateTime.now)
              permission.reload
            end

            permission
          end
        end
      end
    end
  end
end
