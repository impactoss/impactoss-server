class Role
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

      roles.map do |role|
        Role.find_or_create_by!(**role)
      end
    end

    private

    def roles
      [
        {name: "admin", friendly_name: "Admin"},
        {name: "contributor", friendly_name: "Contributor"},
        {name: "manager", friendly_name: "Manager"}
      ]
    end
  end
end
