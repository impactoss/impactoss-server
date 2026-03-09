# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

class Seeds
  def initialize
    base_seeds!
    run_env_seeds!
  end

  private

  def run_env_seeds!
    send(:"#{Rails.env}_seeds!")
  rescue NameError
    log "Seeds for #{Rails.env} not defined, skipping.", level: :warn
  end

  def base_seeds!
    # Set up user roles
    Role.new(name: "admin", friendly_name: "System admin").save!
    Role.new(name: "manager", friendly_name: "Content admin").save!
    # Role.new(name: "contributor", friendly_name: "Contributor").save!

    Page.new(title: "Copyright", menu_title: "Copyright").save!
    Page.new(title: "Disclaimer", menu_title: "Disclaimer").save!
    Page.new(title: "Privacy", menu_title: "Privacy").save!
    Page.new(title: "Accessibility statement", menu_title: "Accessibility").save!
    Page.new(title: "Terms of acceptable use", menu_title: "Terms of acceptable use").save!
    Page.new(title: "About the Human Rights Tracker", menu_title: "About").save!

    # set up frameworks
    hr = Framework.create!(
      title: "International Human Rights Obligations",
      short_title: "HR",
      has_indicators: false,
      has_measures: true,
      has_response: false
    )

    # Set up taxonomies
    # 1. Global taxonomy
    body = Taxonomy.create!(
      framework: hr,
      title: "Human rights instrument",
      tags_users: false,
      tags_measures: false,
      allow_multiple: false,
      has_manager: false,
      priority: 1,
      is_smart: false,
      groups_recommendations_default: 1
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: body
    )
    # 2. Global taxonomy
    cycle = Taxonomy.create!(
      framework: hr,
      title: "Reporting cycle",
      tags_users: false,
      tags_measures: false,
      allow_multiple: false,
      priority: 2,
      is_smart: false,
      groups_recommendations_default: 2,
      parent_id: 1,
      has_date: true
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: cycle
    )
    # 3. National taxonomy
    theme = Taxonomy.create!(
      framework: hr,
      title: "Theme",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 2,
      is_smart: false
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: theme
    )

    # 4. Global taxonomy
    issue = Taxonomy.create!(
      framework: hr,
      title: "Human rights issue",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 3,
      is_smart: false
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: issue
    )

    # 5. Global taxonomy
    group = Taxonomy.create!(
      framework: hr,
      title: "Affected group",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 4,
      is_smart: false
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: group
    )

    # 6. Country specific taxonomy
    # org = Taxonomy.create!(
    #   title: "Government agencies",
    #   tags_measures: true,
    #   tags_users: true,
    #   allow_multiple: true,
    #   priority: 6,
    #   is_smart: false
    # )
    #
    # FrameworkTaxonomy.create!(
    #   framework: hr,
    #   taxonomy: org
    # )
    # 7. Country specific taxonomy
    # smart = Taxonomy.create!(
    #   title: "SMART criteria",
    #   is_smart: true,
    #   tags_measures: true,
    #   tags_users: false,
    #   allow_multiple: true,
    #   priority: 8
    # )
    # # 8. Country specific taxonomy
    # progress = Taxonomy.create!(
    #   title: "Progress status",
    #   is_smart: false,
    #   tags_measures: true,
    #   tags_users: false,
    #   allow_multiple: false,
    #   priority: 7
    # )

    # Set up categories
    # SMART categories
    # smart.categories.create!(
    #   title: "Specific",
    #   short_title: "S",
    #   reference: "1",
    #   description: "The action and associated indicators are clear and concrete. They are focused on a particular programme or activity, or a particular aspect of the programme or activity"
    # )
    # smart.categories.create!(
    #   title: "Measurable",
    #   short_title: "M",
    #   reference: "2",
    #   description: "The indicators should have a clear unit of measurement, such as delivering an aspect of a programme or activity, percentages, numbers or rates."
    # )
    # smart.categories.create!(
    #   title: "Assignable",
    #   short_title: "A",
    #   reference: "3",
    #   description: "An agency is clearly responsible for the action and associated indicators"
    # )
    # smart.categories.create!(
    #   title: "Relevant",
    #   short_title: "R",
    #   reference: "4",
    #   description: "The actions should have a clear relationship to its indicators."
    # )
    # smart.categories.create!(
    #   title: "Time-Bound",
    #   short_title: "T",
    #   reference: "5",
    #   description: "The action should have a clear completion date. Where a completion date is not available due to the ongoing or progressive nature of the action, the indicators should have clear end dates and be measured at specific points in time to track progress against the action."
    # )

    # progress.categories.create!(title: "In preparation", reference: "1")
    # progress.categories.create!(title: "In progress", reference: "2")
    # progress.categories.create!(title: "Completed", reference: "3")

    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    # CRC
    crc = body.categories.create!(
      title: "Convention on the Rights of the Child",
      short_title: "CRC"
    )
    cycle.categories.create!(
      title: "Convention on the Rights of the Child 2023",
      short_title: "CRC-2023",
      reference: "CRC-2023",
      category: crc,
      url: "https://tbinternet.ohchr.org/_layouts/15/treatybodyexternal/Download.aspx?symbolno=CRC%2FC%2FGBR%2FCO%2F6-7&Lang=en",
      date: "2023-06-22"
    )

    # CRPD
    crpd = body.categories.create!(
      title: "Convention on the Rights of Persons with Disabilities",
      short_title: "CRPD"
    )
    cycle.categories.create!(
      title: "Convention on the Rights of Persons with Disabilities 2017",
      short_title: "CRPD-2017",
      reference: "CRPD-2017",
      category: crpd,
      url: "https://tbinternet.ohchr.org/_layouts/15/treatybodyexternal/Download.aspx?symbolno=CRPD%2FC%2FGBR%2FCO%2F1&Lang=en",
      date: "2017-10-03"
    )

    # CEDAW
    cedaw = body.categories.create!(
      title: "Convention on the Elimination of All Forms of Discrimination against Women",
      short_title: "CEDAW"
    )
    cycle.categories.create!(
      title: "Convention on the Elimination of All Forms of Discrimination against Women 2019",
      short_title: "CEDAW-2019",
      reference: "CEDAW-2019",
      category: cedaw,
      url: "https://tbinternet.ohchr.org/_layouts/15/treatybodyexternal/Download.aspx?symbolno=CEDAW%2FC%2FGBR%2FCO%2F8&Lang=en",
      date: "2019-03-14"
    )

    # CERD
    cerd = body.categories.create!(
      title: "International Convention on the Elimination of All Forms of Racial Discrimination",
      short_title: "CERD"
    )
    cycle.categories.create!(
      title: "International Convention on the Elimination of All Forms of Racial Discrimination 2024",
      short_title: "CERD-2024",
      reference: "CERD-2024",
      category: cerd,
      url: "https://tbinternet.ohchr.org/_layouts/15/treatybodyexternal/Download.aspx?symbolno=CERD%2FC%2FGBR%2FCO%2F24-26&Lang=en",
      date: "2024-09-24"
    )

    # ICESCR
    icescr = body.categories.create!(
      title: "International Covenant on Economic, Social and Cultural Rights",
      short_title: "ICESCR"
    )
    cycle.categories.create!(
      title: "International Covenant on Economic, Social and Cultural Rights 2025",
      short_title: "ICESCR-2025",
      reference: "ICESCR-2025",
      category: icescr,
      url: "https://tbinternet.ohchr.org/_layouts/15/treatybodyexternal/Download.aspx?symbolno=E%2FC.12%2FGBR%2FCO%2F7&Lang=en",
      date: "2025-12-03"
    )

    # ICCPR
    iccpr = body.categories.create!(
      title: "International Covenant on Civil and Political Rights",
      short_title: "ICCPR"
    )
    cycle.categories.create!(
      title: "International Covenant on Civil and Political Rights 2024",
      short_title: "ICCPR-2024",
      reference: "ICCPR-2024",
      category: iccpr,
      url: "https://tbinternet.ohchr.org/_layouts/15/treatybodyexternal/Download.aspx?symbolno=CCPR%2FC%2FGBR%2FCO%2F8&Lang=en",
      date: "2024-05-03"
    )
    # Agencies
    # org.categories.create!(
    #   title: "Ministry of Justice",
    #   short_title: "MoJ"
    # )

    # Themes
    theme.categories.create!(
      title: "General measures (Implementation and monitoring)",
      short_title: "General measures"
    )
    theme.categories.create!(
      title: "Equality and inclusion",
      short_title: "Equality/Inclusion"
    )
    theme.categories.create!(
      title: "Fair work, business and economy",
      short_title: "Fair work/business"
    )
    theme.categories.create!(
      title: "Health and social care",
      short_title: "Health"
    )
    theme.categories.create!(
      title: "Living standards",
      short_title: "Living standards"
    )
    theme.categories.create!(
      title: "Education",
      short_title: "Education"
    )
    theme.categories.create!(
      title: "Justice",
      short_title: "Justice"
    )

    # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # Issues
    issue.categories.create!(
      title: "Access to culture",
      short_title: "Culture (access)"
    )
    issue.categories.create!(
      title: "Access to education",
      short_title: "Education (access)"
    )
    issue.categories.create!(
      title: "Access to healthcare",
      short_title: "Healthcare (access)"
    )
    issue.categories.create!(
      title: "Access to justice",
      short_title: "Justice (access)"
    )
    issue.categories.create!(
      title: "Access to public funds",
      short_title: "Public funds (access)"
    )
    issue.categories.create!(
      title: "Access to sports",
      short_title: "Sports (access)"
    )
    issue.categories.create!(
      title: "Accessibility",
      short_title: "Accessibility"
    )
    issue.categories.create!(
      title: "Age of criminal responsibility",
      short_title: "Age criminal resp."
    )
    issue.categories.create!(
      title: "Alcohol and drugs",
      short_title: "Alcohol/drugs"
    )
    issue.categories.create!(
      title: "Allocation of resources",
      short_title: "Resources"
    )
    issue.categories.create!(
      title: "Armed forces",
      short_title: "Armed forces"
    )
    issue.categories.create!(
      title: "Artificial intelligence",
      short_title: "AI"
    )
    issue.categories.create!(
      title: "Asylum",
      short_title: "Asylum"
    )
    issue.categories.create!(
      title: "Best interest of the child",
      short_title: "Best interest"
    )
    issue.categories.create!(
      title: "Bullying and harassment",
      short_title: "Bullying"
    )
    issue.categories.create!(
      title: "Business and human rights",
      short_title: "Business"
    )
    issue.categories.create!(
      title: "Childcare",
      short_title: "Childcare"
    )
    issue.categories.create!(
      title: "Climate Change",
      short_title: "Climate Change"
    )
    issue.categories.create!(
      title: "Conditions of detention",
      short_title: "Detention"
    )
    issue.categories.create!(
      title: "Counter-terrorism",
      short_title: "Counter-terrorism"
    )
    issue.categories.create!(
      title: "COVID-19",
      short_title: "COVID-19"
    )
    issue.categories.create!(
      title: "Cultural diversity",
      short_title: "Cultural"
    )
    issue.categories.create!(
      title: "Data",
      short_title: "Data"
    )
    issue.categories.create!(
      title: "Death by suicide",
      short_title: "Suicide"
    )
    issue.categories.create!(
      title: "Diet, nutrition and healthy weight",
      short_title: "Diet/healthy weight"
    )
    issue.categories.create!(
      title: "Digital access, skills and safety",
      short_title: "Digital"
    )
    issue.categories.create!(
      title: "Discrimination",
      short_title: "Discrimination"
    )
    issue.categories.create!(
      title: "Educational attainment",
      short_title: "Educational attainment"
    )
    issue.categories.create!(
      title: "Environment",
      short_title: "Environment"
    )
    issue.categories.create!(
      title: "Exclusions from school",
      short_title: "Exclusions"
    )
    issue.categories.create!(
      title: "Fair Work",
      short_title: "Fair Work"
    )
    issue.categories.create!(
      title: "Freedom from violence and abuse",
      short_title: "Violence"
    )
    issue.categories.create!(
      title: "Freedom of opinion and expression",
      short_title: "Expression"
    )
    issue.categories.create!(
      title: "Freedom of religion and belief",
      short_title: "Religion/belief"
    )
    issue.categories.create!(
      title: "Housing",
      short_title: "Housing"
    )
    issue.categories.create!(
      title: "Human Rights capability",
      short_title: "HR capability"
    )
    issue.categories.create!(
      title: "Human trafficking and exploitation",
      short_title: "Human trafficking"
    )
    issue.categories.create!(
      title: "Humanitarian emergencies",
      short_title: "Emergencies"
    )
    issue.categories.create!(
      title: "Impact Assessments",
      short_title: "Impact Assessments"
    )
    issue.categories.create!(
      title: "Incorporation",
      short_title: "Incorporation"
    )
    issue.categories.create!(
      title: "International Treaty Reporting",
      short_title: "Reporting"
    )
    issue.categories.create!(
      title: "Legal Aid",
      short_title: "Legal Aid"
    )
    issue.categories.create!(
      title: "Leisure, recreation and play",
      short_title: "Leisure"
    )
    issue.categories.create!(
      title: "Maternity",
      short_title: "Maternity"
    )
    issue.categories.create!(
      title: "Media",
      short_title: "Media"
    )
    issue.categories.create!(
      title: "Mental Health",
      short_title: "Mental Health"
    )
    issue.categories.create!(
      title: "Migration and residence",
      short_title: "Migration"
    )
    issue.categories.create!(
      title: "Mortality",
      short_title: "Mortality"
    )
    issue.categories.create!(
      title: "National Human Rights Institution (NHRI)",
      short_title: "NHRI"
    )
    issue.categories.create!(
      title: "Peaceful assembly",
      short_title: "Assembly"
    )
    issue.categories.create!(
      title: "Pensions",
      short_title: "Pension"
    )
    issue.categories.create!(
      title: "Policies and Strategic Frameworks",
      short_title: "Frameworks"
    )
    issue.categories.create!(
      title: "Policing",
      short_title: "Policing"
    )
    issue.categories.create!(
      title: "Poverty",
      short_title: "Poverty"
    )
    issue.categories.create!(
      title: "Prisons",
      short_title: "Prisons"
    )
    issue.categories.create!(
      title: "Private life and privacy",
      short_title: "Privacy"
    )
    issue.categories.create!(
      title: "Public Sector Equality Duty",
      short_title: "PSED"
    )
    issue.categories.create!(
      title: "Racial profiling",
      short_title: "Racial profiling"
    )
    issue.categories.create!(
      title: "Representation and participation",
      short_title: "Representation"
    )
    issue.categories.create!(
      title: "Reproductive healthcare",
      short_title: "Reproductive"
    )
    issue.categories.create!(
      title: "Respect for family life and parenting",
      short_title: "Family life"
    )
    issue.categories.create!(
      title: "Restraint",
      short_title: "Restraint"
    )
    issue.categories.create!(
      title: "Sex and gender equality",
      short_title: "Sex/gender equality"
    )
    issue.categories.create!(
      title: "Sexual exploitation and prostitution",
      short_title: "SE/Prostitution"
    )
    issue.categories.create!(
      title: "Sexual orientation",
      short_title: "Sexual orientation"
    )
    issue.categories.create!(
      title: "Social care",
      short_title: "Social care"
    )
    issue.categories.create!(
      title: "Social Security",
      short_title: "Social Security"
    )
    issue.categories.create!(
      title: "Stop-and-search",
      short_title: "Stop-and-search"
    )
    issue.categories.create!(
      title: "Support to victims & witnesses",
      short_title: "Victims/witnesses"
    )
    issue.categories.create!(
      title: "Tax",
      short_title: "Tax"
    )
    issue.categories.create!(
      title: "Trade and investment",
      short_title: "Trade"
    )

    # Affected Persons (http://uhri.ohchr.org/search/annotations)
    # Groups
    group.categories.create!(
      title: "Adversely racialised communities",
      short_title: "Race"
    )
    group.categories.create!(
      title: "Care experience",
      short_title: "Care experience"
    )
    group.categories.create!(
      title: "Carers",
      short_title: "Carers"
    )
    group.categories.create!(
      title: "Children and young people",
      short_title: "Children/young people"
    )
    group.categories.create!(
      title: "Disabled people",
      short_title: "Disability",
      description: "A physical or mental impairment with a substantial, long-term effect on day to day activities including long term health conditions, sensory loss, learning disabilities, neurodivergence, mental health conditions, and those diagnosed with progressive conditions (e.g. HIV, cancer, multiple sclerosis)"
    )
    group.categories.create!(
      title: "Faith communities",
      short_title: "Faith"
    )
    group.categories.create!(
      title: "Gypsy/Travellers",
      short_title: "Gypsy/Travellers"
    )
    group.categories.create!(
      title: "Island communities",
      short_title: "Island"
    )
    group.categories.create!(
      title: "LGBTQI+",
      short_title: "LGBTQI+"
    )
    group.categories.create!(
      title: "Migrants",
      short_title: "Migrants"
    )
    group.categories.create!(
      title: "New Scots",
      short_title: "New Scots",
      description: "Forced migrants, including refugees, people seeking asylum, Hong Kong British Nationals (Overseas) and people who are or may become stateless and in need of international protection."
    )
    group.categories.create!(
      title: "Older people",
      short_title: "Older people"
    )
    group.categories.create!(
      title: "People affected by poverty",
      short_title: "Poverty-affected"
    )
    group.categories.create!(
      title: "People deprived of liberty",
      short_title: "Liberty"
    )
    group.categories.create!(
      title: "Rural communities",
      short_title: "Rural"
    )
    group.categories.create!(
      title: "Women and girls",
      short_title: "Women and girls"
    )
    group.categories.create!(
      title: "People affected by substance use",
      short_title: "Substance use"
    )
    group.categories.create!(
      title: "Victims of human trafficking and exploitation",
      short_title: "Victims of trafficking"
    )
  end

  def development_seeds!
    nil unless User.count.zero?
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
