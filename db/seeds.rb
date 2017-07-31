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
        tags_sdgtargets: false,
        allow_multiple: false,
        has_manager: true,
        priority: 1,
        is_smart: false,
      )
    body.save!

    # Global taxonomy
    session = Taxonomy.new(
        title: 'Cycle',
        tags_recommendations: true,
        tags_measures: false,
        tags_users: false,
        allow_multiple: false,
        priority: 2,
        is_smart: false,
        tags_sdgtargets: false,
      )
    session.save!

    # Global taxonomy
    country = Taxonomy.new(
        title: 'Recommending state',
        tags_recommendations: true,
        tags_measures: false,
        tags_users: false,
        tags_sdgtargets: false,
        allow_multiple: false,
        is_smart: false,
        priority: 3
      )
    country.save!

    # Global taxonomy
    sdg = Taxonomy.new(
        title: 'SDGs',
        tags_recommendations: false,
        tags_measures: false,
        tags_users: false,
        tags_sdgtargets: true,
        allow_multiple: false,
        priority: 4,
        is_smart: false,
        groups_sdgtargets_default: 1
      )
    sdg.save!

    # NZ specific taxonomy
    issue = Taxonomy.new(
        title: 'Issues',
        tags_recommendations: true,
        tags_measures: true,
        tags_users: false,
        tags_sdgtargets: false,
        allow_multiple: true,
        priority: 5,
        is_smart: false
      )
    issue.save!

    # NZ specific taxonomy
    groups = Taxonomy.new(
        title: 'Population groups',
        tags_recommendations: true,
        tags_measures: true,
        tags_users: false,
        tags_sdgtargets: false,
        allow_multiple: true,
        priority: 6,
        is_smart: false,
      )
    groups.save!

    # NZ specific taxonomy
    smart = Taxonomy.new(
        title: 'SMART criteria',
        tags_recommendations: false,
        tags_measures: true,
        tags_users: false,
        tags_sdgtargets: false,
        is_smart: true,
        priority: 7,
        allow_multiple: true
      )
    smart.save!

    # NZ specific taxonomy
    org = Taxonomy.new(
        title: 'Government agency',
        tags_recommendations: false,
        tags_measures: true,
        tags_users: true,
        tags_sdgtargets: false,
        allow_multiple: true,
        priority: 8,
        is_smart: false,
      )
    org.save!

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

    # Human Rights Issues
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Equality and non-discrimination in the criminal justice system',
        short_title:'Justice',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Education',
        short_title:'Education',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Health',
        short_title:'Health',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Employment',
        short_title:'Employment',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Harmonious relations',
        short_title:'Relations',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Indigenous rights',
        short_title:'Indigenous',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Canterbury earthquake recovery',
        short_title:'Canterbury',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'International human rights framework',
        short_title:'Framework',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:issue,
        title:'Democratic rights and freedoms',
        short_title:'Democracy',
        description:'',
        url:''
      )

    # Population groups
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'Women',
        short_title:'Women',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'Māori',
        short_title:'Māori',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'Pacific peoples',
        short_title:'Pacific',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'Children',
        short_title:'Children',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'People with disabilities',
        short_title:'Disabilities',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'Refugees, Migrants and Asylum seekers',
        short_title:'Migrants',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'Sexual orientation, Gender identity and Intersex',
        short_title:'SOGII',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'People of Canterbury',
        short_title:'Canterbury',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:groups,
        title:'All people',
        short_title:'All',
        description:'',
        url:''
      )

    # Agencies
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Department of Corrections',
        short_title:'Corrections',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'New Zealand Police',
        short_title:'Police',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry of Justice',
        short_title:'Justice',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry of Social Development',
        short_title:'MSD',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry of Business, Innovation & Employment ',
        short_title:'MBIE',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Office of the Attorney-General',
        short_title:'AGO',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Office of Ethnic Communities',
        short_title:'OEC',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry for Women',
        short_title:'Women',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry of Education',
        short_title:'Education',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Accident Compensation Corporation',
        short_title:'ACC',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Canterbury Earthquake Recovery Authority',
        short_title:'CERA',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Te Taura Whiri i te Reo Māori - Māori Language Commission',
        short_title:'TTW',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry of Health',
        short_title:'Health',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Office of Disability Issues',
        short_title:'ODI',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Ministry of Pacific Island Affairs',
        short_title:'MPIA',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'State Services Commission',
        short_title:'SSC',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'Te Puni Kokiri',
        short_title:'TPK',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:"Children's Action Plan Directorate",
        short_title:'CAP',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'State Services Commission',
        short_title:'SSC',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:org,
        title:'State Services Commission',
        short_title:'SSC',
        description:'',
        url:''
      )

  # SMART
    FactoryGirl.create(
        :category,
        taxonomy:smart,
        title:'Specific',
        short_title:'S',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:smart,
        title:'Measurable',
        short_title:'M',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:smart,
        title:'Assignable',
        short_title:'A',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:smart,
        title:'Result-oriented',
        short_title:'R',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:smart,
        title:'Targeted',
        short_title:'T',
        description:'',
        url:''
      )
    # Countries
    FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Afghanistan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Albania',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Algeria',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Andorra',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Angola',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Argentina',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Armenia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Australia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Austria',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Azerbaijan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bahamas',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bahrain',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bangladesh',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Barbados',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Belarus',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Belgium',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Belize',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Benin',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bhutan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bolivia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bosnia and Herzegovina',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Botswana',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Brazil',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Brunei Darussalam',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Bulgaria',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Burkina Faso',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Burundi',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Cambodia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Cameroon',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Canada',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Cape Verde',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Central African Republic',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Chad',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Chile',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'China',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Colombia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Comoros',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Costa Rica',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Cote d\'Ivoire',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Croatia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Cuba',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Cyprus',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Czechia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'DPR Korea',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Democratic Republic of Congo',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Denmark',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Djibouti',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Dominica',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Dominican Republic',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Ecuador',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Egypt',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'El Salvador',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Equatorial Guinea',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Eritrea',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Estonia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Ethiopia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Fiji',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Finland',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'France',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Gabon',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Gambia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Georgia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Germany',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Ghana',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Greece',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Guatemala',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Guinea',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Guinea Bissau',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Guyana',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Haiti',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Holy See',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Honduras',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Hungary',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Iceland',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'India',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Indonesia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Iran',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Iraq',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Ireland',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Israel',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Italy',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Jamaica',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Japan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Jordan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Kazakhstan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Kenya',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Kiribati',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Kuwait',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Kyrgyzstan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Laos',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Latvia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Lebanon',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Lesotho',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Liberia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Libya',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Liechtenstein',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Lithuania',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Luxembourg',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Macedonia FYR',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Madagascar',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Malawi',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Malaysia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Maldives',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Mali',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Malta',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Marshall Islands',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Mauritania',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Mauritius',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Mexico',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Micronesia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Moldova',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Monaco',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Mongolia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Montenegro',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Morocco',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Mozambique',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Myanmar',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Namibia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Nepal',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Netherlands',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'New Zealand',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Nicaragua',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Niger',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Nigeria',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Norway',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Oman',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Pakistan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Palau',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Palestine',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Panama',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Paraguay',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Peru',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Philippines',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Poland',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Portugal',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Qatar',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Republic of Congo',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Republic of Korea',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Romania',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Russian Federation',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Rwanda',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Samoa',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'San Marino',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Sao Tome & Principe',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Saudi Arabia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Senegal',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Serbia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Seychelles',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Sierra Leone',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Singapore',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Slovakia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Slovenia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Solomon Islands',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Somalia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'South Africa',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'South Sudan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Spain',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Sri Lanka',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'St Kitts & Nevis',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'St Lucia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'St Vincent & the Grenadines',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Sudan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Swaziland',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Sweden',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Switzerland',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Syria',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Tajikistan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Tanzania',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Thailand',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Timor-Leste',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Togo',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Tonga',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Trinidad and Tobago',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Tunisia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Turkey',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Turkmenistan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Tuvalu',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Uganda',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Ukraine',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'United Arab Emirates',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'United Kingdom',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'United States',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Uruguay',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Uzbekistan',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Vanuatu',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Venezuela',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Viet Nam',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Yemen',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Zambia',
  			short_title:'',
  			description:'',
  			url:''
  		)
		FactoryGirl.create(
  			:category,
  			taxonomy:country,
  			title:'Zimbabwe',
  			short_title:'',
  			description:'',
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
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
