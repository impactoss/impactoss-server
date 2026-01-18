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
    Page.new(title: "About the Human Rights Tracker", menu_title: "About").save!

    # set up frameworks
    hr = Framework.create!(
      title: "International Human Rights Obligations",
      short_title: "HR",
      has_indicators: false,
      has_measures: true,
      has_response: true
    )

    # Set up taxonomies
    # 1. Global taxonomy
    body = Taxonomy.create!(
      framework: hr,
      title: "Human rights instrument",
      tags_users: false,
      tags_measures: false,
      allow_multiple: false,
      has_manager: true,
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
      title: "Human rights theme",
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
    icescr = body.categories.create!(
      title: "International Covenant on Economic, Social and Cultural Rights",
      short_title: "ICESCR"
    )
    cycle.categories.create!(
      title: "International Covenant on Economic, Social and Cultural Rights 2025",
      short_title: "ICESCR-2025",
      reference: "ICESCR-2025",
      category: icescr
    )
    iccpr = body.categories.create!(
      title: "International Covenant on Civil and Political Rights",
      short_title: "ICCPR"
    )
    cycle.categories.create!(
      title: "International Covenant on Civil and Political Rights 2024",
      short_title: "ICCPR-2024",
      reference: "ICCPR-2024",
      category: iccpr
    )
    cat = body.categories.create!(
      title: "Convention against Torture and Other Cruel, Inhuman or Degrading Treatment",
      short_title: "CAT"
    )
    cycle.categories.create!(
      title: "Convention against Torture and Other Cruel, Inhuman or Degrading Treatment 2019",
      short_title: "CAT-2019",
      reference: "CAT-2019",
      category: cat
    )
    crc = body.categories.create!(
      title: "Convention on the Rights of the Child",
      short_title: "CRC"
    )
    cycle.categories.create!(
      title: "Convention on the Rights of the Child 2023",
      short_title: "CRC-2023",
      reference: "CRC-2023",
      category: crc
    )
    crpd = body.categories.create!(
      title: "Convention on the Rights of Persons with Disabilities",
      short_title: "CRPD"
    )
    cycle.categories.create!(
      title: "Convention on the Rights of Persons with Disabilities 2017",
      short_title: "CRPD-2017",
      reference: "CRPD-2017",
      category: crpd
    )
    cedaw = body.categories.create!(
      title: "Convention on the Elimination of All Forms of Discrimination against Women",
      short_title: "CEDAW"
    )
    cycle.categories.create!(
      title: "Convention on the Elimination of All Forms of Discrimination against Women 2019",
      short_title: "CEDAW-2019",
      reference: "CEDAW-2019",
      category: cedaw
    )
    cerd = body.categories.create!(
      title: "International Convention on the Elimination of All Forms of Racial Discrimination",
      short_title: "CERD"
    )
    cycle.categories.create!(
      title: "International Convention on the Elimination of All Forms of Racial Discrimination 2024",
      short_title: "CERD-2024",
      reference: "CERD-2024",
      category: cerd
    )
    # Agencies
    # org.categories.create!(
    #   title: "Ministry of Justice",
    #   short_title: "MoJ"
    # )

    # Human Rights Themes
    theme.categories.create!(
      title: "General measures of implementation",
      short_title: "General"
    )
    theme.categories.create!(
      title: "Health",
      short_title: "Health"
    )
    theme.categories.create!(
      title: "Education",
      short_title: "Education"
    )
    theme.categories.create!(
      title: "Work",
      short_title: "Work"
    )
    theme.categories.create!(
      title: "Living standards",
      short_title: "Living standards"
    )
    theme.categories.create!(
      title: "Justice, liberty and personal security",
      short_title: "Justice"
    )
    theme.categories.create!(
      title: "Participation",
      short_title: "Participation"
    )

    # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    issue.categories.create!(
      title: "Data collection and recording",
      short_title: "Data"
    )
    issue.categories.create!(
      title: "Equality and human rights legal framework",
      short_title: "Legal"
    )
    issue.categories.create!(
      title: "Human rights education, trainings and awareness raising",
      short_title: "HR Education"
    )
    issue.categories.create!(
      title: "Institutional, policy and economic frameworks",
      short_title: "IPE frameworks"
    )
    issue.categories.create!(
      title: "International cooperation, including with human rights mechanisms",
      short_title: "Intl. cooperation"
    )
    issue.categories.create!(
      title: "Access to healthcare",
      short_title: "Healthcare"
    )
    issue.categories.create!(
      title: "Health outcomes and experience in the healthcare system",
      short_title: "Health outcomes"
    )
    issue.categories.create!(
      title: "Mental health",
      short_title: "Mental health"
    )
    issue.categories.create!(
      title: "Reproductive and sexual health",
      short_title: "Reproductive health"
    )
    issue.categories.create!(
      title: "Educational attainment",
      short_title: "Education attainment"
    )
    issue.categories.create!(
      title: "Harassment and bullying in schools",
      short_title: "Harassment in schools"
    )
    issue.categories.create!(
      title: "Inclusive education",
      short_title: "Inclusive education"
    )
    issue.categories.create!(
      title: "School exclusions and managing 'challenging behaviour'",
      short_title: "School exclusions"
    )
    issue.categories.create!(
      title: "Access to employment",
      short_title: "Employment access"
    )
    issue.categories.create!(
      title: "Human trafficking and modern slavery",
      short_title: "Trafficking"
    )
    issue.categories.create!(
      title: "Just and fair conditions at work",
      short_title: "Work conditions"
    )
    issue.categories.create!(
      title: "Occupational segregation",
      short_title: "Occupational segregation"
    )
    issue.categories.create!(
      title: "Adequate standard of living and poverty",
      short_title: "Living standards"
    )
    issue.categories.create!(
      title: "Housing",
      short_title: "Housing"
    )
    issue.categories.create!(
      title: "Social care",
      short_title: "Social care"
    )
    issue.categories.create!(
      title: "Social security (welfare benefits)",
      short_title: "Social security"
    )
    issue.categories.create!(
      title: "Access to justice, including fair trials",
      short_title: "Access to justice"
    )
    issue.categories.create!(
      title: "Counter-terrorism",
      short_title: "Counter-terrorism"
    )
    issue.categories.create!(
      title: "Criminal justice institutions",
      short_title: "Criminal justice"
    )
    issue.categories.create!(
      title: "Hate crime and hate speech",
      short_title: "Hate crime & speech"
    )
    issue.categories.create!(
      title: "Human rights abuses abroad",
      short_title: "HR abuses abroad"
    )
    issue.categories.create!(
      title: "Immigration",
      short_title: "Immigration"
    )
    issue.categories.create!(
      title: "Mental health detention",
      short_title: "Mental health detention"
    )
    issue.categories.create!(
      title: "Policing",
      short_title: "Policing"
    )
    issue.categories.create!(
      title: "Violence against women and girls",
      short_title: "Violence against women & girls"
    )
    issue.categories.create!(
      title: "Violence, abuse and neglect, and child sexual exploitation",
      short_title: "Child abuse & neglect"
    )
    issue.categories.create!(
      title: "Youth justice",
      short_title: "Youth justice"
    )
    issue.categories.create!(
      title: "Family life, and rest, leisure and cultural activities",
      short_title: "Family life"
    )
    issue.categories.create!(
      title: "Independent living",
      short_title: "Independent living"
    )
    issue.categories.create!(
      title: "Political and civic participation",
      short_title: "Political participation"
    )
    issue.categories.create!(
      title: "Privacy",
      short_title: "Privacy"
    )

    # Affected Persons (http://uhri.ohchr.org/search/annotations)
    group.categories.create!(
      title: "Age (children)",
      short_title: "Children"
    )
    group.categories.create!(
      title: "Age (older people)",
      short_title: "Older people"
    )
    group.categories.create!(
      title: "Disability",
      short_title: "Disability"
    )
    group.categories.create!(
      title: "Gender reassignment",
      short_title: "Gender reassignment"
    )
    group.categories.create!(
      title: "Intersex",
      short_title: "Intersex"
    )
    group.categories.create!(
      title: "Marriage and civil partnership",
      short_title: "Marriage & partnership"
    )
    group.categories.create!(
      title: "Migration background / status",
      short_title: "Migration"
    )
    group.categories.create!(
      title: "Pregnancy and maternity",
      short_title: "Maternity"
    )
    group.categories.create!(
      title: "Race and ethnicity",
      short_title: "Race & ethnicity"
    )
    group.categories.create!(
      title: "Religion or belief",
      short_title: "Religion/belief"
    )
    group.categories.create!(
      title: "Sex (female)",
      short_title: "Sex (female)"
    )
    group.categories.create!(
      title: "Sex (male)",
      short_title: "Sex (male)"
    )
    group.categories.create!(
      title: "Sexual orientation",
      short_title: "Sexual orientation"
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
