# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class Seeds
  def initialize
    base_seeds!
    run_env_seeds!
  end

  private

  def run_env_seeds!
    send("#{Rails.env}_seeds!")
  rescue NameError
    log "Seeds for #{Rails.env} not defined, skipping.", level: :warn
  end

  def base_seeds!
    # Set up user roles
    Role.new(name: "admin", friendly_name: "Admin").save!
    Role.new(name: "manager", friendly_name: "Manager").save!
    Role.new(name: "contributor", friendly_name: "Contributor").save!

    # set up frameworks ########################################################
    fw1 = Framework.new(
      title: "Framework 1",
      short_title: "FW1",
      has_indicators: false,
      has_measures: true,
      has_response: true
    )
    fw1.save!

    # Set up taxonomies ########################################################
    #  Sample taxonomy
    t1 = FactoryBot.create(
      :taxonomy,
      framework: fw1,
      title: "Tax 1",
      tags_measures: false,
      tags_users: false,
      allow_multiple: false,
      has_manager: true,
      priority: 11,
      groups_recommendations_default: 1
    )
    FactoryBot.create(
      :framework_taxonomy,
      framework: fw1,
      taxonomy: t1
    )

    # Set up categories ########################################################
    FactoryBot.create(
      :category,
      taxonomy: t1,
      title: "Cat 1",
      reference: "1"
    )
  end

  def development_seeds!
    return unless User.count.zero?
    FactoryBot.create(:user).tap do |user|
      log "Seed user created: Log in with #{user.email} and password #{user.password}"
      user.roles << Role.find_by(name: "manager")
      user.save!
    end
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
