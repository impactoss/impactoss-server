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
    Role.new(name: 'admin', friendly_name: 'Admin').save!
    Role.new(name: 'manager', friendly_name: 'Manager').save!
    Role.new(name: 'contributor', friendly_name: 'Contributor').save!

    # Set up taxonomies
    # Global taxonomy
    body = Taxonomy.new(
        title: 'Human rights body',
        tags_recommendations: true,
        tags_measures: false,
        allow_multiple: false
      ).save!
    # Global taxonomy
    session = Taxonomy.new(
        title: 'UN session',
        tags_recommendations: true,
        tags_measures: false,
        allow_multiple: false
      ).save!
    # Global taxonomy
    right = Taxonomy.new(
        title: 'Human right',
        tags_recommendations: true,
        tags_measures: false,
        allow_multiple: true
      ).save!
    # Global taxonomy
    persons = Taxonomy.new(
        title: 'Affected persons',
        tags_recommendations: true,
        tags_measures: false,
        allow_multiple: true
      ).save!
    # Samoa specific taxonomy
    cluster = Taxonomy.new(
        title: 'Thematic cluster',
        tags_recommendations: true,
        tags_measures: false,
        allow_multiple: true
      ).save!
    # Samoa specific taxonomy
    org = Taxonomy.new(
        title: 'Organisation',
        tags_recommendations: false,
        tags_measures: true,
        allow_multiple: false
      ).save!


    # Set up categories
    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Universal Periodic Review',
        short_title:'UPR',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Human Rights Committee',
        short_title:'CCPR',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Economic, Social and Cultural Rights',
        short_title:'CESCR',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Elimination of Racial Discrimination',
        short_title:'CERD',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Elimination of Discrimination against Women',
        short_title:'CEDAW',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee against Torture',
        short_title:'CAT',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Subcommittee on Prevention of Torture',
        short_title:'SPT',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Rights of the Child',
        short_title:'CRC',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Migrant Workers',
        short_title:'CMW',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Rights of Persons with Disabilities',
        short_title:'CRPD',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Enforced Disappearances',
        short_title:'CED',
        description:''
      )

    # TODO UN Sessions

    # Human Rights (level 1 http://uhri.ohchr.org/search/annotations)
    # TODO level 2 and 3 human rights
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'A General framework of implementation',
        short_title:'A',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'B Universal or cross-cutting issues',
        short_title:'B',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'D Civil & political rights',
        short_title:'D',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'E Economic, social and cultural rights',
        short_title:'E',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'F Specific persons or groups',
        short_title:'F',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'G1 Members of minorities',
        short_title:'G1',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'G3 Indigenous peoples',
        short_title:'G3',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'G4 Migrants',
        short_title:'G4',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'G5 Refugees & asylum seekers',
        short_title:'G5',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'G6 Internally displaced persons',
        short_title:'G6',
        description:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'H1 Human rights defenders',
        short_title:'H1',
        description:''
      )


      # Affected Persons (http://uhri.ohchr.org/search/annotations)
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Children',
          short_title:'Children',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Children in street situations',
          short_title:'CSS',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Disappeared persons',
          short_title:'Disappeared',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Educational staff',
          short_title:'Edu',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'General',
          short_title:'General',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Girls',
          short_title:'Girls',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Human rights defenders',
          short_title:'HRD',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Indigenous peoples',
          short_title:'Indigenous',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Internally displaced persons',
          short_title:'IDP',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Judges, lawyers and prosecutors',
          short_title:'JLP',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Law enforcement / police officials',
          short_title:'Law',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Lesbian, gay, bisexual and transgender and intersex persons (LGBTI)',
          short_title:'LGBTI',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Media',
          short_title:'Media',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Medical staff',
          short_title:'Medical',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Mercenaries',
          short_title:'Mercenaries',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Migrants',
          short_title:'Migrants',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Military staff',
          short_title:'Military',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Minorities / racial, ethnic, linguistic, religious or descent-based groups',
          short_title:'Minorities',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Non-citizens',
          short_title:'Non-citizens',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Older persons',
          short_title:'Old',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons affected by armed conflict',
          short_title:'Armed conflict',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons deprived of their liberty',
          short_title:'Liberty',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons living in poverty',
          short_title:'Poverty',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons living in rural areas',
          short_title:'Rural',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons living with HIV/AIDS',
          short_title:'HIV',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons with disabilities',
          short_title:'Disabilities',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Prison officials',
          short_title:'Prison officials',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Private security',
          short_title:'Private security',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Public officials',
          short_title:'Public officials',
          description:''
        )
        FactoryGirl.create(
            :category,
            taxonomy:persons,
            title:'Refugees & asylum seekers',
            short_title:'Refugees',
            description:''
          )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Rural women',
          short_title:'Rural women',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Social workers',
          short_title:'Social workers',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Stateless persons',
          short_title:'Stateless',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Vulnerable persons/groups',
          short_title:'Vulnerable',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Women',
          short_title:'Women',
          description:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Youth',
          short_title:'Youth',
          description:''
        )

    # create test data, configure in spec/factories/
    FactoryGirl.create_list(:recommendation_measure, 50)
    FactoryGirl.create_list(:recommendation_category, 50)
    FactoryGirl.create_list(:measure_indicator, 50)
    FactoryGirl.create_list(:measure_category, 50)

    # category_1 = FactoryGirl.create(:category, title: 'Children', short_title: 'Children')
    # recommendation_1 = FactoryGirl.create(:recommendation, title: 'Consider the implications of signing and ratifying the Optional Protocol to the Convention on the Rights of the Child-Individual Communications', number: 3)
    # measure_1 = FactoryGirl.create(:measure, title: 'Consider the implications of signing and ratifying the Optional Protocol to the Convention on the Rights of the Child-Individual Communications', description: 'New Zealand began the process to establish a position on signing and ratifying the OP-CRC in May 2015 in consultation with relevant teams from the Ministries of Social Development, Foreign Affairs and Trade, and Justice.  An initial report will be provided to the Minister for Social Development by 30 June 2016 with recommendations on New Zealand’s position. Next steps to be determined by 31 December 2016.', target_date: Date.today)
    #
    # FactoryGirl.create(:recommendation_category, recommendation: recommendation_1, category: category_1)
    # FactoryGirl.create(:recommendation_measure, recommendation: recommendation_1, measure: measure_1 )
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
