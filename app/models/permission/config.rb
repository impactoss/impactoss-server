class Permission
  module Config
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
      read_operations +
        write_operations +
        permission_operations
    end

    def self.organisation_only_resources
      %w[]
    end

    def self.user_only_resources
      %w[bookmark]
    end

    # Format: {
    #   (resource) => {
    #     (operation) => ["status"]
    #   }
    # }
    def self.public_operations
      {
        "category" => {
          "read" => ["active"]
        },
        "recommendation_measure" => {
          "read" => ["active"]
        }
      }
    end

    def self.resources
      shared_resources + owned_resources
    end

    def self.shared_resources
      %w[
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
      %w[active archived draft owner]
    end
  end
end
