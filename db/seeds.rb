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
    # Role.new(name: 'admin', friendly_name: 'Admin').save!
    # Role.new(name: 'manager', friendly_name: 'Manager').save!
    # Role.new(name: 'contributor', friendly_name: 'Contributor').save!
    #
    # # Set up taxonomies
    # # id 1
    # body = Taxonomy.new(
    #     title: 'Human rights mechanism',
    #     tags_recommendations: true,
    #     tags_measures: false,
    #     tags_users: false,
    #     allow_multiple: false,
    #     has_manager: true,
    #     priority: 5,
    #     is_smart: false,
    #     tags_sdgtargets: false
    #   )
    # body.save!
    #
    # # id 2
    # session = Taxonomy.new(
    #     title: 'Reporting cycle',
    #     tags_recommendations: true,
    #     tags_measures: false,
    #     tags_users: false,
    #     allow_multiple: false,
    #     priority: 6,
    #     is_smart: false,
    #     tags_sdgtargets: false,
    #   )
    # session.save!
    # # id 3
    # cluster = Taxonomy.new(
    #     title: 'Recommendation cluster',
    #     tags_recommendations: true,
    #     tags_measures: true,
    #     tags_users: false,
    #     allow_multiple: true,
    #     priority: 1,
    #     is_smart: false,
    #     tags_sdgtargets: false,
    #     groups_measures_default: 1,
    #     groups_recommendations_default: 1,
    #   )
    # cluster.save!
    # # id 4
    # agency = Taxonomy.new(
    #     title: 'Implementing agency',
    #     tags_recommendations: false,
    #     tags_measures: true,
    #     tags_users: false,
    #     allow_multiple: true,
    #     priority: 10,
    #     is_smart: false,
    #     tags_sdgtargets: false,
    #   )
    # agency.save!
    #
    # # id 5
    # issue = Taxonomy.new(
    #     title: 'Theme',
    #     tags_recommendations: true,
    #     tags_measures: false,
    #     tags_users: false,
    #     allow_multiple: true,
    #     priority: 2,
    #     is_smart: false,
    #     tags_sdgtargets: false
    #   )
    # issue.save!
    # # id 6
    # right = Taxonomy.new(
    #     title: 'Human rights',
    #     tags_recommendations: true,
    #     tags_measures: false,
    #     tags_users: false,
    #     allow_multiple: true,
    #     priority: 3,
    #     is_smart: false,
    #     tags_sdgtargets: false
    #   )
    # right.save!
    #
    # # id 7
    # persons = Taxonomy.new(
    #     title: 'Affected persons',
    #     tags_recommendations: true,
    #     tags_measures: false,
    #     tags_users: false,
    #     allow_multiple: true,
    #     priority: 4,
    #     is_smart: false,
    #     tags_sdgtargets: false
    #   )
    # persons.save!
    #

    # id 8
    sdg = Taxonomy.new(
        title: 'SDGs',
        tags_recommendations: false,
        tags_measures: false,
        tags_users: false,
        tags_sdgtargets: true,
        allow_multiple: false,
        priority: 20,
        is_smart: false,
        groups_sdgtargets_default: 1
      )
    sdg.save!
    # SDGs
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'End poverty in all its forms everywhere',
         title:'No poverty',
         reference: 1,
         short_title:'SDG 1',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'End hunger, achieve food security and improved nutrition and promote sustainable agriculture',
         title:'Zero hunger',
         reference: 2,
         short_title:'SDG 2',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Ensure healthy lives and promote well-being for all at all ages',
         title:'Good Health and Well-being',
         reference: 3,
         short_title:'SDG 3',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all',
         title:'Quality Education',
         reference: 4,
         short_title:'SDG 4',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Achieve gender equality and empower all women and girls',
         title:'Gender Equality',
         reference: 5,
         short_title:'SDG 5',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Ensure availability and sustainable management of water and sanitation for all',
         title:'Clean Water and Sanitation',
         reference: 6,
         short_title:'SDG 6',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Ensure access to affordable, reliable, sustainable and modern energy for all',
         title:'Affordable and Clean Energy',
         reference: 7,
         short_title:'SDG 7',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all',
         title:'Decent Work and Economic Growth',
         reference: 8,
         short_title:'SDG 8',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation',
         title:'Industry, Innovation and Infrastructure',
         reference: 9,
         short_title:'SDG 9',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Reduce income inequality within and among countries',
         title:'Reduced Inequalities',
         reference: 10,
         short_title:'SDG 10',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Make cities and human settlements inclusive, safe, resilient and sustainable',
         title:'Sustainable Cities and Communities',
         reference: 11,
         short_title:'SDG 11',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Ensure sustainable consumption and production patterns',
         title:'Responsible Consumption and Production',
         reference: 12,
         short_title:'SDG 12',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Take urgent action to combat climate change and its impacts by regulating emissions and promoting developments in renewable energy',
         title:'Climate Action',
         reference: 13,
         short_title:'SDG 13',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Conserve and sustainably use the oceans, seas and marine resources for sustainable development',
         title:'Life Below Water',
         reference: 14,
         short_title:'SDG 14',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss',
         title:'Life on Land',
         reference: 15,
         short_title:'SDG 15',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels',
         title:'Peace, Justice and Strong Institutions',
         reference: 16,
         short_title:'SDG 16',
         url:''
       )
     FactoryGirl.create(
         :category,
         taxonomy:sdg,
         description:'Strengthen the means of implementation and revitalize the global partnership for sustainable development',
         title:'Partnerships for the Goals',
         reference: 17,
         short_title:'SDG 17',
         url:''
       )
    #
    # # Set up categories
    # # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Universal Periodic Review',
    #     short_title:'UPR',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Human Rights Committee',
    #     short_title:'CCPR',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on Economic, Social and Cultural Rights',
    #     short_title:'CESCR',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on the Elimination of Racial Discrimination',
    #     short_title:'CERD',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on the Elimination of Discrimination against Women',
    #     short_title:'CEDAW',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee against Torture',
    #     short_title:'CAT',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Subcommittee on Prevention of Torture',
    #     short_title:'SPT',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on the Rights of the Child',
    #     short_title:'CRC',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on Migrant Workers',
    #     short_title:'CMW',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on the Rights of Persons with Disabilities',
    #     short_title:'CRPD',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:body,
    #     title:'Committee on Enforced Disappearances',
    #     short_title:'CED',
    #     description:'',
    #     url:''
    #   )
    #
    #   # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # # TODO level 2 and 3 human rights
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Scope of international obligations',
    #     short_title:'Int. obligations',
    #     reference:'A1',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Cooperation with human rights mechanisms and institutions',
    #     short_title:'Cooperation ',
    #     reference:'A2',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Inter-State cooperation & development assistance',
    #     short_title:'Inter-State cooperation',
    #     reference:'A3',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Legal, institutional and policy framework',
    #     short_title:'Framework',
    #     reference:'A4',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Human rights education, trainings and awareness raising',
    #     short_title:'HR education',
    #     reference:'A5',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Context, statistics, budget, civil society',
    #     short_title:'Context',
    #     reference:'A6',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'International criminal and humanitarian law',
    #     short_title:'Int. law',
    #     reference:'B1',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to self-determination',
    #     short_title:'Self-determination',
    #     reference:'B2',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Equality and non-discrimination',
    #     short_title:'Equality',
    #     reference:'B3',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to development',
    #     short_title:'Development',
    #     reference:'B4',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to a remedy',
    #     short_title:'Remedy',
    #     reference:'B5',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Business & Human Rights',
    #     short_title:'Business',
    #     reference:'B6',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Human rights and environmental issues',
    #     short_title:'Environment',
    #     reference:'B7',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Human rights & counter-terrorism',
    #     short_title:'Counter-terrorism',
    #     reference:'B8',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Human rights & use of mercenaries',
    #     short_title:'Mercenaries',
    #     reference:'B9',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Civil & political rights - general measures of implementation',
    #     short_title:'Civil & political',
    #     reference:'D1',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to physical and moral integrity',
    #     short_title:'Integrity',
    #     reference:'D2',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Liberty and security of the person',
    #     short_title:'Liberty',
    #     reference:'D3',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Fundamental freedoms',
    #     short_title:'Freedoms',
    #     reference:'D4',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Administration of justice',
    #     short_title:'Justice',
    #     reference:'D5',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Rights related to name, identity, nationality',
    #     short_title:'Identity',
    #     reference:'D6',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to participation in public affairs and right to vote',
    #     short_title:'Participation',
    #     reference:'D7',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Rights related to marriage & family',
    #     short_title:'Family',
    #     reference:'D8',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Economic, social & cultural rights - general measures of implementation',
    #     short_title:'Economic, social & cultural',
    #     reference:'E1',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to an adequate standard of living',
    #     short_title:'Standard of living',
    #     reference:'E2',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Labour rights',
    #     short_title:'Labour rights',
    #     reference:'E3',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to health',
    #     short_title:'Health',
    #     reference:'E4',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Right to education',
    #     short_title:'Education',
    #     reference:'E5',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Rights to protection of property; financial credit',
    #     short_title:'Property',
    #     reference:'E6',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Cultural rights',
    #     short_title:'Cultural rights',
    #     reference:'E7',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Women',
    #     short_title:'Women',
    #     reference:'F1',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Children',
    #     short_title:'Children',
    #     reference:'F3',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Persons with disabilities',
    #     short_title:'Persons with disabilities',
    #     reference:'F4',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Members of minorities',
    #     short_title:'Minorities',
    #     reference:'G1',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Indigenous peoples',
    #     short_title:'Indigenous peoples',
    #     reference:'G3',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Migrants',
    #     short_title:'Migrants',
    #     reference:'G4',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Refugees & asylum seekers',
    #     short_title:'Refugees',
    #     reference:'G5',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Internally displaced persons',
    #     short_title:'Internally displaced',
    #     reference:'G5',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:issue,
    #     title:'Human rights defenders',
    #     short_title:'HR defenders',
    #     reference:'H1',
    #     description:'',
    #     url:''
    #   )
    #
    #
    # # Affected Persons (http://uhri.ohchr.org/search/annotations)
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Children',
    #     short_title:'Children',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Children in street situations',
    #     short_title:'CSS',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Disappeared persons',
    #     short_title:'Disappeared',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Educational staff',
    #     short_title:'Edu',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'General',
    #     short_title:'General',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Girls',
    #     short_title:'Girls',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Human rights defenders',
    #     short_title:'HRD',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Indigenous peoples',
    #     short_title:'Indigenous',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Internally displaced persons',
    #     short_title:'IDP',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Judges, lawyers and prosecutors',
    #     short_title:'JLP',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Law enforcement / police officials',
    #     short_title:'Law',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Lesbian, gay, bisexual and transgender and intersex persons (LGBTI)',
    #     short_title:'LGBTI',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Media',
    #     short_title:'Media',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Medical staff',
    #     short_title:'Medical',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Mercenaries',
    #     short_title:'Mercenaries',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Migrants',
    #     short_title:'Migrants',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Military staff',
    #     short_title:'Military',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Minorities / racial, ethnic, linguistic, religious or descent-based groups',
    #     short_title:'Minorities',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Non-citizens',
    #     short_title:'Non-citizens',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Older persons',
    #     short_title:'Old',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Persons affected by armed conflict',
    #     short_title:'Armed conflict',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Persons deprived of their liberty',
    #     short_title:'Liberty',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Persons living in poverty',
    #     short_title:'Poverty',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Persons living in rural areas',
    #     short_title:'Rural',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Persons living with HIV/AIDS',
    #     short_title:'HIV',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Persons with disabilities',
    #     short_title:'Disabilities',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Prison officials',
    #     short_title:'Prison officials',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Private security',
    #     short_title:'Private security',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Public officials',
    #     short_title:'Public officials',
    #     description:'',
    #     url:''
    #   )
    #   FactoryGirl.create(
    #       :category,
    #       taxonomy:persons,
    #       title:'Refugees & asylum seekers',
    #       short_title:'Refugees',
    #       description:'',
    #       url:''
    #     )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Rural women',
    #     short_title:'Rural women',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Social workers',
    #     short_title:'Social workers',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Stateless persons',
    #     short_title:'Stateless',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Vulnerable persons/groups',
    #     short_title:'Vulnerable',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Women',
    #     short_title:'Women',
    #     description:'',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:persons,
    #     title:'Youth',
    #     short_title:'Youth',
    #     description:'',
    #     url:''
    #   )
    #
    # // UDHR Human Rights
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     title:'All human beings are born free and equal in dignity and rights. They are endowed with reason and conscience and should act towards one another in a spirit of brotherhood.',
    #     short_title:'Article 1',
    #     title:'Right to Equality',
    #     reference:'1',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone is entitled to all the rights and freedoms set forth in this Declaration, without distinction of any kind, such as race, colour, sex, language, religion, political or other opinion, national or social origin, property, birth or other status. Furthermore, no distinction shall be made on the basis of the political, jurisdictional or international status of the country or territory to which a person belongs, whether it be independent, trust, non-self-governing or under any other limitation of sovereignty.',
    #     short_title:'Article 2',
    #     title:'Freedom from Discrimination',
    #     reference:'2',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone has the right to life, liberty and security of person.',
    #     short_title:'Article 3',
    #     title:'Right to Life, Liberty, Personal Security',
    #     reference:'3',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'No one shall be held in slavery or servitude; slavery and the slave trade shall be prohibited in all their forms.',
    #     short_title:'Article 4',
    #     title:'Freedom from Slavery',
    #     reference:'4',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'No one shall be subjected to torture or to cruel, inhuman or degrading treatment or punishment.',
    #     short_title:'Article 5',
    #     title:'Freedom from Torture and Degrading Treatment',
    #     reference:'5',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'No one shall be subjected to torture or to cruel, inhuman or degrading treatment or punishment.',
    #     short_title:'Article 5',
    #     title:'Right to Recognition as a Person before the Law',
    #     reference:'5',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone has the right to recognition everywhere as a person before the law.',
    #     short_title:'Article 6',
    #     title:'Right to Equality before the Law',
    #     reference:'6',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'All are equal before the law and are entitled without any discrimination to equal protection of the law. All are entitled to equal protection against any discrimination in violation of this Declaration and against any incitement to such discrimination.',
    #     short_title:'Article 7',
    #     title:'Right to Remedy by Competent Tribunal',
    #     reference:'7',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone has the right to an effective remedy by the competent national tribunals for acts violating the fundamental rights granted him by the constitution or by law.',
    #     short_title:'Article 8',
    #     title:'',
    #     reference:'8',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'No one shall be subjected to arbitrary arrest, detention or exile.',
    #     short_title:'Article 9',
    #     title:'Freedom from Arbitrary Arrest and Exile',
    #     reference:'9',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone is entitled in full equality to a fair and public hearing by an independent and impartial tribunal, in the determination of his rights and obligations and of any criminal charge against him.',
    #     short_title:'Article 10',
    #     title:'Right to Fair Public Hearing',
    #     reference:'10',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone charged with a penal offence has the right to be presumed innocent until proved guilty according to law in a public trial at which he has had all the guarantees necessary for his defence. (2) No one shall be held guilty of any penal offence on account of any act or omission which did not constitute a penal offence, under national or international law, at the time when it was committed. Nor shall a heavier penalty be imposed than the one that was applicable at the time the penal offence was committed.',
    #     short_title:'Article 11',
    #     title:'Right to be Considered Innocent until Proven Guilty',
    #     reference:'11',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'No one shall be subjected to arbitrary interference with his privacy, family, home or correspondence, nor to attacks upon his honour and reputation. Everyone has the right to the protection of the law against such interference or attacks.',
    #     short_title:'Article 12',
    #     title:'Freedom from Interference with Privacy, Family, Home and Correspondence',
    #     reference:'12',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to freedom of movement and residence within the borders of each state. (2) Everyone has the right to leave any country, including his own, and to return to his country.',
    #     short_title:'Article 13',
    #     title:'Right to Free Movement in and out of the Country',
    #     reference:'13',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to seek and to enjoy in other countries asylum from persecution. (2) This right may not be invoked in the case of prosecutions genuinely arising from non-political crimes or from acts contrary to the purposes and principles of the United Nations.',
    #     short_title:'Article 14',
    #     title:'Right to Asylum in other Countries from Persecution',
    #     reference:'14',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to a nationality. (2) No one shall be arbitrarily deprived of his nationality nor denied the right to change his nationality.',
    #     short_title:'Article 15',
    #     title:'Right to a Nationality and the Freedom to Change It',
    #     reference:'15',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Men and women of full age, without any limitation due to race, nationality or religion, have the right to marry and to found a family. They are entitled to equal rights as to marriage, during marriage and at its dissolution. (2) Marriage shall be entered into only with the free and full consent of the intending spouses. (3) The family is the natural and fundamental group unit of society and is entitled to protection by society and the State.',
    #     short_title:'Article 16',
    #     title:'Right to Asylum in other Countries from Persecution',
    #     reference:'16',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to own property alone as well as in association with others. (2) No one shall be arbitrarily deprived of his property.',
    #     short_title:'Article 17',
    #     title:'Right to Own Property',
    #     reference:'17',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone has the right to freedom of thought, conscience and religion; this right includes freedom to change his religion or belief, and freedom, either alone or in community with others and in public or private, to manifest his religion or belief in teaching, practice, worship and observance.',
    #     short_title:'Article 18',
    #     title:'Freedom of Belief and Religion',
    #     reference:'18',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone has the right to freedom of opinion and expression; this right includes freedom to hold opinions without interference and to seek, receive and impart information and ideas through any media and regardless of frontiers.',
    #     short_title:'Article 19',
    #     title:'Freedom of Opinion and Information',
    #     reference:'19',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to freedom of peaceful assembly and association. (2) No one may be compelled to belong to an association.',
    #     short_title:'Article 20',
    #     title:'Right of Peaceful Assembly and Association',
    #     reference:'20',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to take part in the government of his country, directly or through freely chosen representatives. (2) Everyone has the right of equal access to public service in his country. (3) The will of the people shall be the basis of the authority of government; this will shall be expressed in periodic and genuine elections which shall be by universal and equal suffrage and shall be held by secret vote or by equivalent free voting procedures.',
    #     short_title:'Article 21',
    #     title:'Right to Participate in Government and in Free Elections',
    #     reference:'21',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone, as a member of society, has the right to social security and is entitled to realization, through national effort and international co-operation and in accordance with the organization and resources of each State, of the economic, social and cultural rights indispensable for his dignity and the free development of his personality.',
    #     short_title:'Article 22',
    #     title:'Right to Social Security',
    #     reference:'22',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to work, to free choice of employment, to just and favourable conditions of work and to protection against unemployment. (2) Everyone, without any discrimination, has the right to equal pay for equal work. (3) Everyone who works has the right to just and favourable remuneration ensuring for himself and his family an existence worthy of human dignity, and supplemented, if necessary, by other means of social protection. (4) Everyone has the right to form and to join trade unions for the protection of his interests.',
    #     short_title:'Article 23',
    #     title:'Right to Desirable Work and to Join Trade Unions',
    #     reference:'23',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone has the right to rest and leisure, including reasonable limitation of working hours and periodic holidays with pay.',
    #     short_title:'Article 24',
    #     title:'Right to Rest and Leisure',
    #     reference:'24',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to a standard of living adequate for the health and well-being of himself and of his family, including food, clothing, housing and medical care and necessary social services, and the right to security in the event of unemployment, sickness, disability, widowhood, old age or other lack of livelihood in circumstances beyond his control. (2) Motherhood and childhood are entitled to special care and assistance. All children, whether born in or out of wedlock, shall enjoy the same social protection.',
    #     short_title:'Article 25',
    #     title:'Right to Adequate Living Standard',
    #     reference:'25',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right to education. Education shall be free, at least in the elementary and fundamental stages. Elementary education shall be compulsory. Technical and professional education shall be made generally available and higher education shall be equally accessible to all on the basis of merit. (2) Education shall be directed to the full development of the human personality and to the strengthening of respect for human rights and fundamental freedoms. It shall promote understanding, tolerance and friendship among all nations, racial or religious groups, and shall further the activities of the United Nations for the maintenance of peace. (3) Parents have a prior right to choose the kind of education that shall be given to their children.',
    #     short_title:'Article 26',
    #     title:'Right to Education',
    #     reference:'26',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has the right freely to participate in the cultural life of the community, to enjoy the arts and to share in scientific advancement and its benefits. (2) Everyone has the right to the protection of the moral and material interests resulting from any scientific, literary or artistic production of which he is the author.',
    #     short_title:'Article 27',
    #     title:'Right to Participate in the Cultural Life of Community',
    #     reference:'27',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Everyone is entitled to a social and international order in which the rights and freedoms set forth in this Declaration can be fully realized.',
    #     short_title:'Article 28',
    #     title:'Right to a Social Order that Articulates this Document',
    #     reference:'28',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'(1) Everyone has duties to the community in which alone the free and full development of his personality is possible. (2) In the exercise of his rights and freedoms, everyone shall be subject only to such limitations as are determined by law solely for the purpose of securing due recognition and respect for the rights and freedoms of others and of meeting the just requirements of morality, public order and the general welfare in a democratic society. (3) These rights and freedoms may in no case be exercised contrary to the purposes and principles of the United Nations.',
    #     short_title:'Article 29',
    #     title:'Community Duties Essential to Free and Full Development',
    #     reference:'29',
    #     url:''
    #   )
    # FactoryGirl.create(
    #     :category,
    #     taxonomy:right,
    #     description:'Nothing in this Declaration may be interpreted as implying for any State, group or person any right to engage in any activity or to perform any act aimed at the destruction of any of the rights and freedoms set forth herein.',
    #     short_title:'Article 30',
    #     title:'Freedom from State or Personal Interference in the above Rights',
    #     reference:'30',
    #     url:''
    #   )

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
