class Role
  class Setup
    def self.call(**args)
      new.call(**args)
    end

    def call(intended_environment:)
      if intended_environment != Rails.env || Rails.env.nil?
        raise "You must specify the intended environment to run this setup script. This is to prevent accidental execution in sensitive environments like production."
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
