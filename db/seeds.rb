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
    Role.new(name: 'admin', friendly_name: 'Admin').save!
    Role.new(name: 'manager', friendly_name: 'Manager').save!
    Role.new(name: 'contributor', friendly_name: 'Contributor').save!

    FactoryGirl.create_list(:recommendation_measure, 50)
    FactoryGirl.create_list(:recommendation_category, 50)
    FactoryGirl.create_list(:measure_indicator, 50)
    FactoryGirl.create_list(:measure_category, 50)

    category_1 = FactoryGirl.create(:category, title: 'Children', short_title: 'Children')
    recommendation_1 = FactoryGirl.create(:recommendation, title: 'Consider the implications of signing and ratifying the Optional Protocol to the Convention on the Rights of the Child-Individual Communications', number: 3)
    measure_1 = FactoryGirl.create(:measure, title: 'Consider the implications of signing and ratifying the Optional Protocol to the Convention on the Rights of the Child-Individual Communications', description: 'New Zealand began the process to establish a position on signing and ratifying the OP-CRC in May 2015 in consultation with relevant teams from the Ministries of Social Development, Foreign Affairs and Trade, and Justice.  An initial report will be provided to the Minister for Social Development by 30 June 2016 with recommendations on New Zealand’s position. Next steps to be determined by 31 December 2016.', target_date: Date.today)

    FactoryGirl.create(:recommendation_category, recommendation: recommendation_1, category: category_1)
    FactoryGirl.create(:recommendation_measure, recommendation: recommendation_1, measure: measure_1 )
  end

  def development_seeds!
    return unless User.count.zero?
    FactoryGirl.create(:user).tap do |user|
      log "Seed user created: Log in with #{user.email} and password #{user.password}"
      user.roles << Role.find_by(name: 'manager')
      user.save!
    end
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
