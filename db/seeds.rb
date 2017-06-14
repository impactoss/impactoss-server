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
        tags_users: false,
        allow_multiple: false,
        has_manager: true
      )
    body.save!

    # Global taxonomy
    session = Taxonomy.new(
        title: 'Cycle',
        tags_recommendations: true,
        tags_measures: false,
        tags_users: false,
        allow_multiple: false
      )
    session.save!

    # Global taxonomy
    right = Taxonomy.new(
        title: 'Human rights issue',
        tags_recommendations: true,
        tags_measures: false,
        tags_users: false,
        allow_multiple: true
      )
    right.save!

    # Global taxonomy
    persons = Taxonomy.new(
        title: 'Affected persons',
        tags_recommendations: true,
        tags_measures: false,
        tags_users: false,
        allow_multiple: true
      )
    persons.save!
    # Samoa specific taxonomy
    cluster = Taxonomy.new(
        title: 'Thematic cluster',
        tags_recommendations: true,
        tags_measures: false,
        tags_users: false,
        allow_multiple: true
      )
    cluster.save!

    # Samoa specific taxonomy
    org = Taxonomy.new(
        title: 'Organisation',
        tags_recommendations: false,
        tags_measures: true,
        tags_users: true,
        allow_multiple: true
      )
    org.save!

    # Global taxonomy
    sdg = Taxonomy.new(
        title: 'SDGs',
        tags_recommendations: false,
        tags_measures: false,
        tags_users: false,
        tags_sdgtargets: true,
        allow_multiple: false
      )
    sdg.save!

    # Set up categories
    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Universal Periodic Review',
        short_title:'UPR',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Human Rights Committee',
        short_title:'CCPR',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Economic, Social and Cultural Rights',
        short_title:'CESCR',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Elimination of Racial Discrimination',
        short_title:'CERD',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Elimination of Discrimination against Women',
        short_title:'CEDAW',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee against Torture',
        short_title:'CAT',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Subcommittee on Prevention of Torture',
        short_title:'SPT',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Rights of the Child',
        short_title:'CRC',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Migrant Workers',
        short_title:'CMW',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Rights of Persons with Disabilities',
        short_title:'CRPD',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Enforced Disappearances',
        short_title:'CED',
        description:'',
        url:''
      )

    # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # TODO level 2 and 3 human rights
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Scope of international obligations',
        short_title:'A1',
        reference: 'A1'
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Cooperation with human rights mechanisms and institutions',
        short_title:'A2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Inter-State cooperation & development assistance',
        short_title:'A3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Legal, institutional and policy framework',
        short_title:'A4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights education, trainings and awareness raising',
        short_title:'A5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Context, statistics, budget, civil society',
        short_title:'A6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'International criminal and humanitarian law',
        short_title:'B1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to self-determination',
        short_title:'B2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Equality and non-discrimination',
        short_title:'B3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to development',
        short_title:'B4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to a remedy',
        short_title:'B5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Business & Human Rights',
        short_title:'B6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights and environmental issues',
        short_title:'B7',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights & counter-terrorism',
        short_title:'B8',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights & use of mercenaries',
        short_title:'B9',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Civil & political rights - general measures of implementation',
        short_title:'D1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to physical and moral integrity',
        short_title:'D2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Liberty and security of the person',
        short_title:'D3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Fundamental freedoms',
        short_title:'D4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Administration of justice',
        short_title:'D5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Rights related to name, identity, nationality',
        short_title:'D6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to participation in public affairs and right to vote',
        short_title:'D7',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Rights related to marriage & family',
        short_title:'D8',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Economic, social & cultural rights - general measures of implementation',
        short_title:'E1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to an adequate standard of living',
        short_title:'E2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Labour rights',
        short_title:'E3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to health',
        short_title:'E4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to education',
        short_title:'E5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Rights to protection of property; financial credit',
        short_title:'E6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Cultural rights',
        short_title:'E7',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Women',
        short_title:'F1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Children',
        short_title:'F3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Persons with disabilities',
        short_title:'F4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Members of minorities',
        short_title:'G1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Indigenous peoples',
        short_title:'G3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Migrants',
        short_title:'G4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Refugees & asylum seekers',
        short_title:'G5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Internally displaced persons',
        short_title:'G5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights defendersh',
        short_title:'H1',
        description:'',
        url:''
      )


      # Affected Persons (http://uhri.ohchr.org/search/annotations)
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Children',
          short_title:'Children',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Children in street situations',
          short_title:'CSS',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Disappeared persons',
          short_title:'Disappeared',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Educational staff',
          short_title:'Edu',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'General',
          short_title:'General',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Girls',
          short_title:'Girls',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Human rights defenders',
          short_title:'HRD',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Indigenous peoples',
          short_title:'Indigenous',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Internally displaced persons',
          short_title:'IDP',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Judges, lawyers and prosecutors',
          short_title:'JLP',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Law enforcement / police officials',
          short_title:'Law',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Lesbian, gay, bisexual and transgender and intersex persons (LGBTI)',
          short_title:'LGBTI',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Media',
          short_title:'Media',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Medical staff',
          short_title:'Medical',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Mercenaries',
          short_title:'Mercenaries',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Migrants',
          short_title:'Migrants',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Military staff',
          short_title:'Military',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Minorities / racial, ethnic, linguistic, religious or descent-based groups',
          short_title:'Minorities',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Non-citizens',
          short_title:'Non-citizens',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Older persons',
          short_title:'Old',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons affected by armed conflict',
          short_title:'Armed conflict',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons deprived of their liberty',
          short_title:'Liberty',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons living in poverty',
          short_title:'Poverty',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons living in rural areas',
          short_title:'Rural',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons living with HIV/AIDS',
          short_title:'HIV',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Persons with disabilities',
          short_title:'Disabilities',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Prison officials',
          short_title:'Prison officials',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Private security',
          short_title:'Private security',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Public officials',
          short_title:'Public officials',
          description:'',
          url:''
        )
        FactoryGirl.create(
            :category,
            taxonomy:persons,
            title:'Refugees & asylum seekers',
            short_title:'Refugees',
            description:'',
            url:''
          )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Rural women',
          short_title:'Rural women',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Social workers',
          short_title:'Social workers',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Stateless persons',
          short_title:'Stateless',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Vulnerable persons/groups',
          short_title:'Vulnerable',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Women',
          short_title:'Women',
          description:'',
          url:''
        )
      FactoryGirl.create(
          :category,
          taxonomy:persons,
          title:'Youth',
          short_title:'Youth',
          description:'',
          url:''
        )
        # SDGs
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'End poverty in all its forms everywhere',
            title:'No poverty',
            number: 1,
            short_title:'SDG 1',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'End hunger, achieve food security and improved nutrition and promote sustainable agriculture',
            title:'Zero hunger',
            number: 2,
            short_title:'SDG 2',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Ensure healthy lives and promote well-being for all at all ages',
            title:'Good Health and Well-being',
            number: 3,
            short_title:'SDG 3',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all',
            title:'Quality Education',
            number: 4,
            short_title:'SDG 4',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Achieve gender equality and empower all women and girls',
            title:'Gender Equality',
            number: 5,
            short_title:'SDG 5',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Ensure availability and sustainable management of water and sanitation for all',
            title:'Clean Water and Sanitation',
            number: 6,
            short_title:'SDG 6',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Ensure access to affordable, reliable, sustainable and modern energy for all',
            title:'Affordable and Clean Energy',
            number: 7,
            short_title:'SDG 7',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all',
            title:'Decent Work and Economic Growth',
            number: 8,
            short_title:'SDG 8',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation',
            title:'Industry, Innovation and Infrastructure',
            number: 9,
            short_title:'SDG 9',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Reduce income inequality within and among countries',
            title:'Reduced Inequalities',
            number: 10,
            short_title:'SDG 10',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Make cities and human settlements inclusive, safe, resilient and sustainable',
            title:'Sustainable Cities and Communities',
            number: 11,
            short_title:'SDG 11',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Ensure sustainable consumption and production patterns',
            title:'Responsible Consumption and Production',
            number: 12,
            short_title:'SDG 12',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Take urgent action to combat climate change and its impacts by regulating emissions and promoting developments in renewable energy',
            title:'Climate Action',
            number: 13,
            short_title:'SDG 13',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Conserve and sustainably use the oceans, seas and marine resources for sustainable development',
            title:'Life Below Water',
            number: 14,
            short_title:'SDG 14',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss',
            title:'Life on Land',
            number: 15,
            short_title:'SDG 15',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels',
            title:'Peace, Justice and Strong Institutions',
            number: 16,
            short_title:'SDG 16',
            url:''
          )
        FactoryGirl.create(
            :category,
            taxonomy:sdg,
            description:'Strengthen the means of implementation and revitalize the global partnership for sustainable development',
            title:'Partnerships for the Goals',
            number: 17,
            short_title:'SDG 17',
            url:''
          )
  end

  def development_seeds!
    return unless User.count.zero?
    FactoryGirl.create(:user).tap do |user|
      log "Seed user created: Log in with #{user.email} and password #{user.password}"
      user.roles << Role.find_by(name: 'manager')
      user.save!
    end

    # create test data, configure in spec/factories/
    # FactoryGirl.create_list(:recommendation, 50)
    # FactoryGirl.create_list(:measure, 50)
    # FactoryGirl.create_list(:indicator, 50)

    # FactoryGirl.create_list(:category, 10, taxonomy: org)
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
