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
    Role.new(name: "admin", friendly_name: "Admin").save!
    Role.new(name: "manager", friendly_name: "Manager").save!
    Role.new(name: "contributor", friendly_name: "Contributor").save!

    Page.new(title: "Copyright", menu_title: "Copyright").save!
    Page.new(title: "Disclaimer", menu_title: "Disclaimer").save!
    Page.new(title: "Privacy", menu_title: "Privacy").save!
    Page.new(title: "About IMPACT OSS", menu_title: "About").save!

    # set up frameworks
    hr = Framework.create!(
      title: "International Human Rights Obligations",
      short_title: "HR",
      has_indicators: false,
      has_measures: true,
      has_response: true
    )
    sdgfw = Framework.new(
      title: "Sustainable Development Goals",
      short_title: "SDGs",
      has_indicators: true,
      has_measures: true,
      has_response: false
    )
    sdgfw.save!

    ndp = Framework.create!(
      title: "National Development Plan",
      short_title: "NDP",
      has_indicators: true,
      has_measures: true,
      has_response: false
    )

    # Set up taxonomies
    # 1. Global taxonomy
    body = Taxonomy.create!(
      framework: hr,
      title: "Human rights body",
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
      title: "Cycle",
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
    # 3. Global taxonomy
    country = Taxonomy.create!(
      framework: hr,
      title: "Recommending state",
      tags_measures: false,
      tags_users: false,
      allow_multiple: false,
      priority: 2,
      is_smart: false
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: country
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
    persons = Taxonomy.create!(
      framework: hr,
      title: "Affected persons",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 4,
      is_smart: false
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: persons
    )

    # 6. Country specific taxonomy
    org = Taxonomy.create!(
      title: "Government agencies",
      tags_measures: true,
      tags_users: true,
      allow_multiple: true,
      priority: 6,
      is_smart: false
    )

    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: org
    )
    # 7. Country specific taxonomy
    smart = Taxonomy.create!(
      title: "SMART criteria",
      is_smart: true,
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 8
    )
    # 8. Country specific taxonomy
    progress = Taxonomy.create!(
      title: "Progress status",
      is_smart: false,
      tags_measures: true,
      tags_users: false,
      allow_multiple: false,
      priority: 7
    )

    # 9. Country specific taxonomy
    cluster = Taxonomy.create!(
      title: "Thematic cluster",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 100,
      groups_measures_default: 1
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: cluster
    )
    FrameworkTaxonomy.create!(
      framework: sdgfw,
      taxonomy: cluster
    )
    FrameworkTaxonomy.create!(
      framework: ndp,
      taxonomy: cluster
    )
    # 10. Global taxonomy
    sdg = Taxonomy.create!(
      framework: sdgfw,
      title: "SDGs",
      has_manager: true,
      allow_multiple: true,
      priority: 31,
      tags_measures: false,
      tags_users: false
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: sdg
    )
    FrameworkTaxonomy.create!(
      framework: sdgfw,
      taxonomy: sdg
    )

    # Set up categories
    # SMART categories
    smart.categories.create!(
      title: "Specific",
      short_title: "S",
      reference: "1",
      description: "The action and associated indicators are clear and concrete. They are focused on a particular programme or activity, or a particular aspect of the programme or activity"
    )
    smart.categories.create!(
      title: "Measurable",
      short_title: "M",
      reference: "2",
      description: "The indicators should have a clear unit of measurement, such as delivering an aspect of a programme or activity, percentages, numbers or rates."
    )
    smart.categories.create!(
      title: "Assignable",
      short_title: "A",
      reference: "3",
      description: "An agency is clearly responsible for the action and associated indicators"
    )
    smart.categories.create!(
      title: "Relevant",
      short_title: "R",
      reference: "4",
      description: "The actions should have a clear relationship to its indicators."
    )
    smart.categories.create!(
      title: "Time-Bound",
      short_title: "T",
      reference: "5",
      description: "The action should have a clear completion date. Where a completion date is not available due to the ongoing or progressive nature of the action, the indicators should have clear end dates and be measured at specific points in time to track progress against the action."
    )

    progress.categories.create!(title: "In preparation", reference: "1")
    progress.categories.create!(title: "In progress", reference: "2")
    progress.categories.create!(title: "Completed", reference: "3")

    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    upr = body.categories.create!(
      title: "Human rights council (UPR)",
      short_title: "UPR"
    )
    cycle.categories.create!(
      title: "Universal Periodic Review 2024",
      short_title: "UPR-2024",
      reference: "UPR-2024",
      category: upr
    )
    body.categories.create!(
      title: "International Covenant on Civil and Political Rights",
      short_title: "ICCPR"
    )
    body.categories.create!(
      title: "International Covenant on Economic Social and Cultural Rights",
      short_title: "ICESCR"
    )
    body.categories.create!(
      title: "Committee Against Torture and Other Cruel, Inhuman or Degrading Treatment or Punishment",
      short_title: "CAT"
    )
    body.categories.create!(
      title: "Committee for the Elimination of All Forms of Racial Discrimination",
      short_title: "CERD"
    )
    body.categories.create!(
      title: "Committee for the Elimination of All Forms of Discrimination Against Women",
      short_title: "CEDAW"
    )
    body.categories.create!(
      title: "Committee on the Rights of the Child",
      short_title: "CRC"
    )
    body.categories.create!(
      title: "Committee on the Rights of Persons with Disabilities",
      short_title: "CRPD"
    )
    # Agencies
    org.categories.create!(
      title: "Ministry of Justice",
      short_title: "MoJ"
    )
    org.categories.create!(
      title: "Ministry of Foreign Affairs and Trade",
      short_title: "MFAT"
    )

    # # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # # TODO level 2 and 3 human rights
    issue.categories.create!(
      title: "Scope of international obligations",
      short_title: "Int. obligations",
      reference: "A1",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Cooperation with human rights mechanisms and institutions",
      short_title: "Cooperation ",
      reference: "A2",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Inter-State cooperation & development assistance",
      short_title: "Inter-State cooperation",
      reference: "A3",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Legal, institutional and policy framework",
      short_title: "Framework",
      reference: "A4",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Human rights education, trainings and awareness raising",
      short_title: "HR education",
      reference: "A5",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Context, statistics, budget, civil society",
      short_title: "Context",
      reference: "A6",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "International criminal and humanitarian law",
      short_title: "Int. law",
      reference: "B1",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to self-determination",
      short_title: "Self-determination",
      reference: "B2",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Equality and non-discrimination",
      short_title: "Equality",
      reference: "B3",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to development",
      short_title: "Development",
      reference: "B4",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to a remedy",
      short_title: "Remedy",
      reference: "B5",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Business & Human Rights",
      short_title: "Business",
      reference: "B6",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Human rights and environmental issues",
      short_title: "Environment",
      reference: "B7",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Human rights & counter-terrorism",
      short_title: "Counter-terrorism",
      reference: "B8",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Human rights & use of mercenaries",
      short_title: "Mercenaries",
      reference: "B9",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Civil & political rights - general measures of implementation",
      short_title: "Civil & political",
      reference: "D1",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to physical and moral integrity",
      short_title: "Integrity",
      reference: "D2",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Liberty and security of the person",
      short_title: "Liberty",
      reference: "D3",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Fundamental freedoms",
      short_title: "Freedoms",
      reference: "D4",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Administration of justice",
      short_title: "Justice",
      reference: "D5",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Rights related to name, identity, nationality",
      short_title: "Identity",
      reference: "D6",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to participation in public affairs and right to vote",
      short_title: "Participation",
      reference: "D7",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Rights related to marriage & family",
      short_title: "Family",
      reference: "D8",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Economic, social & cultural rights - general measures of implementation",
      short_title: "Economic, social & cultural",
      reference: "E1",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to an adequate standard of living",
      short_title: "Standard of living",
      reference: "E2",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Labour rights",
      short_title: "Labour rights",
      reference: "E3",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to health",
      short_title: "Health",
      reference: "E4",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Right to education",
      short_title: "Education",
      reference: "E5",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Rights to protection of property; financial credit",
      short_title: "Property",
      reference: "E6",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Cultural rights",
      short_title: "Cultural rights",
      reference: "E7",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Women",
      short_title: "Women",
      reference: "F1",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Children",
      short_title: "Children",
      reference: "F3",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Persons with disabilities",
      short_title: "Persons with disabilities",
      reference: "F4",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Members of minorities",
      short_title: "Minorities",
      reference: "G1",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Indigenous peoples",
      short_title: "Indigenous peoples",
      reference: "G3",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Migrants",
      short_title: "Migrants",
      reference: "G4",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Refugees & asylum seekers",
      short_title: "Refugees",
      reference: "G5",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Internally displaced persons",
      short_title: "Internally displaced",
      reference: "G5",
      description: "",
      url: ""
    )
    issue.categories.create!(
      title: "Human rights defenders",
      short_title: "HR defenders",
      reference: "H1",
      description: "",
      url: ""
    )

    # Affected Persons (http://uhri.ohchr.org/search/annotations)
    persons.categories.create!(
      title: "Children",
      short_title: "Children",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Children in street situations",
      short_title: "CSS",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Disappeared persons",
      short_title: "Disappeared",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Educational staff",
      short_title: "Edu",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "General",
      short_title: "General",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Girls",
      short_title: "Girls",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Human rights defenders",
      short_title: "HRD",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Indigenous peoples",
      short_title: "Indigenous",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Internally displaced persons",
      short_title: "IDP",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Judges, lawyers and prosecutors",
      short_title: "JLP",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Law enforcement / police officials",
      short_title: "Law",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Lesbian, gay, bisexual and transgender and intersex persons (LGBTI)",
      short_title: "LGBTI",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Media",
      short_title: "Media",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Medical staff",
      short_title: "Medical",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Mercenaries",
      short_title: "Mercenaries",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Migrants",
      short_title: "Migrants",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Military staff",
      short_title: "Military",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Minorities / racial, ethnic, linguistic, religious or descent-based groups",
      short_title: "Minorities",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Non-citizens",
      short_title: "Non-citizens",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Older persons",
      short_title: "Old",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Persons affected by armed conflict",
      short_title: "Armed conflict",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Persons deprived of their liberty",
      short_title: "Liberty",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Persons living in poverty",
      short_title: "Poverty",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Persons living in rural areas",
      short_title: "Rural",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Persons living with HIV/AIDS",
      short_title: "HIV",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Persons with disabilities",
      short_title: "Disabilities",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Prison officials",
      short_title: "Prison officials",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Private security",
      short_title: "Private security",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Public officials",
      short_title: "Public officials",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Refugees & asylum seekers",
      short_title: "Refugees",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Rural women",
      short_title: "Rural women",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Social workers",
      short_title: "Social workers",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Stateless persons",
      short_title: "Stateless",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Vulnerable persons/groups",
      short_title: "Vulnerable",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Women",
      short_title: "Women",
      description: "",
      url: ""
    )
    persons.categories.create!(
      title: "Youth",
      short_title: "Youth",
      description: "",
      url: ""
    )
    # Countries
    country.categories.create!(
      short_title: "AFG",
      title: "Afghanistan"
    )
    country.categories.create!(
      short_title: "ALB",
      title: "Albania"
    )
    country.categories.create!(
      short_title: "DZA",
      title: "Algeria"
    )
    country.categories.create!(
      short_title: "AND",
      title: "Andorra"
    )
    country.categories.create!(
      short_title: "AGO",
      title: "Angola"
    )
    country.categories.create!(
      short_title: "ATG",
      title: "Antigua and Barbuda"
    )
    country.categories.create!(
      short_title: "ARG",
      title: "Argentina"
    )
    country.categories.create!(
      short_title: "ARM",
      title: "Armenia"
    )
    country.categories.create!(
      short_title: "AUS",
      title: "Australia"
    )
    country.categories.create!(
      short_title: "AUT",
      title: "Austria"
    )
    country.categories.create!(
      short_title: "AZE",
      title: "Azerbaijan"
    )
    country.categories.create!(
      short_title: "BHS",
      title: "Bahamas"
    )
    country.categories.create!(
      short_title: "BHR",
      title: "Bahrain"
    )
    country.categories.create!(
      short_title: "BGD",
      title: "Bangladesh"
    )
    country.categories.create!(
      short_title: "BRB",
      title: "Barbados"
    )
    country.categories.create!(
      short_title: "BLR",
      title: "Belarus"
    )
    country.categories.create!(
      short_title: "BEL",
      title: "Belgium"
    )
    country.categories.create!(
      short_title: "BLZ",
      title: "Belize"
    )
    country.categories.create!(
      short_title: "BEN",
      title: "Benin"
    )
    country.categories.create!(
      short_title: "BTN",
      title: "Bhutan"
    )
    country.categories.create!(
      short_title: "BOL",
      title: "Bolivia (Plurinational State of)"
    )
    country.categories.create!(
      short_title: "BIH",
      title: "Bosnia and Herzegovina"
    )
    country.categories.create!(
      short_title: "BWA",
      title: "Botswana"
    )
    country.categories.create!(
      short_title: "BRA",
      title: "Brazil"
    )
    country.categories.create!(
      short_title: "BRN",
      title: "Brunei Darussalam"
    )
    country.categories.create!(
      short_title: "BGR",
      title: "Bulgaria"
    )
    country.categories.create!(
      short_title: "BFA",
      title: "Burkina Faso"
    )
    country.categories.create!(
      short_title: "BDI",
      title: "Burundi"
    )
    country.categories.create!(
      short_title: "CPV",
      title: "Cabo Verde"
    )
    country.categories.create!(
      short_title: "KHM",
      title: "Cambodia"
    )
    country.categories.create!(
      short_title: "CMR",
      title: "Cameroon"
    )
    country.categories.create!(
      short_title: "CAN",
      title: "Canada"
    )
    country.categories.create!(
      short_title: "CAF",
      title: "Central African Republic"
    )
    country.categories.create!(
      short_title: "TCD",
      title: "Chad"
    )
    country.categories.create!(
      short_title: "CHL",
      title: "Chile"
    )
    country.categories.create!(
      short_title: "CHN",
      title: "China"
    )
    country.categories.create!(
      short_title: "COL",
      title: "Colombia"
    )
    country.categories.create!(
      short_title: "COM",
      title: "Comoros"
    )
    country.categories.create!(
      short_title: "COG",
      title: "Congo"
    )
    country.categories.create!(
      short_title: "COK",
      title: "Cook Islands"
    )
    country.categories.create!(
      short_title: "CRI",
      title: "Costa Rica"
    )
    country.categories.create!(
      short_title: "CIV",
      title: "Côte d'Ivoire"
    )
    country.categories.create!(
      short_title: "HRV",
      title: "Croatia"
    )
    country.categories.create!(
      short_title: "CUB",
      title: "Cuba"
    )
    country.categories.create!(
      short_title: "CYP",
      title: "Cyprus"
    )
    country.categories.create!(
      short_title: "CZE",
      title: "Czechia"
    )
    country.categories.create!(
      short_title: "PRK",
      title: "Democratic People's Republic of Korea"
    )
    country.categories.create!(
      short_title: "COD",
      title: "Democratic Republic of the Congo"
    )
    country.categories.create!(
      short_title: "DNK",
      title: "Denmark"
    )
    country.categories.create!(
      short_title: "DJI",
      title: "Djibouti"
    )
    country.categories.create!(
      short_title: "DMA",
      title: "Dominica"
    )
    country.categories.create!(
      short_title: "DOM",
      title: "Dominican Republic"
    )
    country.categories.create!(
      short_title: "ECU",
      title: "Ecuador"
    )
    country.categories.create!(
      short_title: "EGY",
      title: "Egypt"
    )
    country.categories.create!(
      short_title: "SLV",
      title: "El Salvador"
    )
    country.categories.create!(
      short_title: "GNQ",
      title: "Equatorial Guinea"
    )
    country.categories.create!(
      short_title: "ERI",
      title: "Eritrea"
    )
    country.categories.create!(
      short_title: "EST",
      title: "Estonia"
    )
    country.categories.create!(
      short_title: "SWZ",
      title: "Eswatini"
    )
    country.categories.create!(
      short_title: "ETH",
      title: "Ethiopia"
    )
    country.categories.create!(
      short_title: "FJI",
      title: "Fiji"
    )
    country.categories.create!(
      short_title: "FIN",
      title: "Finland"
    )
    country.categories.create!(
      short_title: "FRA",
      title: "France"
    )
    country.categories.create!(
      short_title: "GAB",
      title: "Gabon"
    )
    country.categories.create!(
      short_title: "GMB",
      title: "Gambia"
    )
    country.categories.create!(
      short_title: "GEO",
      title: "Georgia"
    )
    country.categories.create!(
      short_title: "DEU",
      title: "Germany"
    )
    country.categories.create!(
      short_title: "GHA",
      title: "Ghana"
    )
    country.categories.create!(
      short_title: "GRC",
      title: "Greece"
    )
    country.categories.create!(
      short_title: "GRD",
      title: "Grenada"
    )
    country.categories.create!(
      short_title: "GTM",
      title: "Guatemala"
    )
    country.categories.create!(
      short_title: "GNB",
      title: "Guinea-Bissau"
    )
    country.categories.create!(
      short_title: "GIN",
      title: "Guinea"
    )
    country.categories.create!(
      short_title: "GUY",
      title: "Guyana"
    )
    country.categories.create!(
      short_title: "HTI",
      title: "Haiti"
    )
    country.categories.create!(
      short_title: "VAT",
      title: "Holy See"
    )
    country.categories.create!(
      short_title: "HND",
      title: "Honduras"
    )
    country.categories.create!(
      short_title: "HUN",
      title: "Hungary"
    )
    country.categories.create!(
      short_title: "ISL",
      title: "Iceland"
    )
    country.categories.create!(
      short_title: "IND",
      title: "India"
    )
    country.categories.create!(
      short_title: "IDN",
      title: "Indonesia"
    )
    country.categories.create!(
      short_title: "IRN",
      title: "Iran (Islamic Republic of)"
    )
    country.categories.create!(
      short_title: "IRQ",
      title: "Iraq"
    )
    country.categories.create!(
      short_title: "IRL",
      title: "Ireland"
    )
    country.categories.create!(
      short_title: "ISR",
      title: "Israel"
    )
    country.categories.create!(
      short_title: "ITA",
      title: "Italy"
    )
    country.categories.create!(
      short_title: "JAM",
      title: "Jamaica"
    )
    country.categories.create!(
      short_title: "JPN",
      title: "Japan"
    )
    country.categories.create!(
      short_title: "JOR",
      title: "Jordan"
    )
    country.categories.create!(
      short_title: "KAZ",
      title: "Kazakhstan"
    )
    country.categories.create!(
      short_title: "KEN",
      title: "Kenya"
    )
    country.categories.create!(
      short_title: "KIR",
      title: "Kiribati"
    )
    country.categories.create!(
      short_title: "KWT",
      title: "Kuwait"
    )
    country.categories.create!(
      short_title: "KGZ",
      title: "Kyrgyzstan"
    )
    country.categories.create!(
      short_title: "LAO",
      title: "Lao People's Democratic Republic"
    )
    country.categories.create!(
      short_title: "LVA",
      title: "Latvia"
    )
    country.categories.create!(
      short_title: "LBN",
      title: "Lebanon"
    )
    country.categories.create!(
      short_title: "LSO",
      title: "Lesotho"
    )
    country.categories.create!(
      short_title: "LBR",
      title: "Liberia"
    )
    country.categories.create!(
      short_title: "LBY",
      title: "Libya"
    )
    country.categories.create!(
      short_title: "LIE",
      title: "Liechtenstein"
    )
    country.categories.create!(
      short_title: "LTU",
      title: "Lithuania"
    )
    country.categories.create!(
      short_title: "LUX",
      title: "Luxembourg"
    )
    country.categories.create!(
      short_title: "MDG",
      title: "Madagascar"
    )
    country.categories.create!(
      short_title: "MWI",
      title: "Malawi"
    )
    country.categories.create!(
      short_title: "MYS",
      title: "Malaysia"
    )
    country.categories.create!(
      short_title: "MDV",
      title: "Maldives"
    )
    country.categories.create!(
      short_title: "MLI",
      title: "Mali"
    )
    country.categories.create!(
      short_title: "MLT",
      title: "Malta"
    )
    country.categories.create!(
      short_title: "MHL",
      title: "Marshall Islands"
    )
    country.categories.create!(
      short_title: "MRT",
      title: "Mauritania"
    )
    country.categories.create!(
      short_title: "MUS",
      title: "Mauritius"
    )
    country.categories.create!(
      short_title: "MEX",
      title: "Mexico"
    )
    country.categories.create!(
      short_title: "FSM",
      title: "Micronesia (Federated States of)"
    )
    country.categories.create!(
      short_title: "MCO",
      title: "Monaco"
    )
    country.categories.create!(
      short_title: "MNG",
      title: "Mongolia"
    )
    country.categories.create!(
      short_title: "MNE",
      title: "Montenegro"
    )
    country.categories.create!(
      short_title: "MAR",
      title: "Morocco"
    )
    country.categories.create!(
      short_title: "MOZ",
      title: "Mozambique"
    )
    country.categories.create!(
      short_title: "MMR",
      title: "Myanmar"
    )
    country.categories.create!(
      short_title: "NAM",
      title: "Namibia"
    )
    country.categories.create!(
      short_title: "NRU",
      title: "Nauru"
    )
    country.categories.create!(
      short_title: "NPL",
      title: "Nepal"
    )
    country.categories.create!(
      short_title: "NLD",
      title: "Netherlands"
    )
    country.categories.create!(
      short_title: "NZL",
      title: "New Zealand"
    )
    country.categories.create!(
      short_title: "NIC",
      title: "Nicaragua"
    )
    country.categories.create!(
      short_title: "NER",
      title: "Niger"
    )
    country.categories.create!(
      short_title: "NGA",
      title: "Nigeria"
    )
    country.categories.create!(
      short_title: "NIU",
      title: "Niue"
    )
    country.categories.create!(
      short_title: "MKD",
      title: "North Macedonia"
    )
    country.categories.create!(
      short_title: "NOR",
      title: "Norway"
    )
    country.categories.create!(
      short_title: "OMN",
      title: "Oman"
    )
    country.categories.create!(
      short_title: "PAK",
      title: "Pakistan"
    )
    country.categories.create!(
      short_title: "PLW",
      title: "Palau"
    )
    country.categories.create!(
      short_title: "PAN",
      title: "Panama"
    )
    country.categories.create!(
      short_title: "PNG",
      title: "Papua New Guinea"
    )
    country.categories.create!(
      short_title: "PRY",
      title: "Paraguay"
    )
    country.categories.create!(
      short_title: "PER",
      title: "Peru"
    )
    country.categories.create!(
      short_title: "PHL",
      title: "Philippines"
    )
    country.categories.create!(
      short_title: "POL",
      title: "Poland"
    )
    country.categories.create!(
      short_title: "PRT",
      title: "Portugal"
    )
    country.categories.create!(
      short_title: "QAT",
      title: "Qatar"
    )
    country.categories.create!(
      short_title: "KOR",
      title: "Republic of Korea"
    )
    country.categories.create!(
      short_title: "MDA",
      title: "Republic of Moldova"
    )
    country.categories.create!(
      short_title: "ROU",
      title: "Romania"
    )
    country.categories.create!(
      short_title: "RUS",
      title: "Russian Federation"
    )
    country.categories.create!(
      short_title: "RWA",
      title: "Rwanda"
    )
    country.categories.create!(
      short_title: "KNA",
      title: "Saint Kitts and Nevis"
    )
    country.categories.create!(
      short_title: "LCA",
      title: "Saint Lucia"
    )
    country.categories.create!(
      short_title: "VCT",
      title: "Saint Vincent and the Grenadines"
    )
    country.categories.create!(
      short_title: "WSM",
      title: "Samoa"
    )
    country.categories.create!(
      short_title: "SMR",
      title: "San Marino"
    )
    country.categories.create!(
      short_title: "STP",
      title: "São Tomé and Principe"
    )
    country.categories.create!(
      short_title: "SAU",
      title: "Saudi Arabia"
    )
    country.categories.create!(
      short_title: "SEN",
      title: "Senegal"
    )
    country.categories.create!(
      short_title: "SRB",
      title: "Serbia"
    )
    country.categories.create!(
      short_title: "SYC",
      title: "Seychelles"
    )
    country.categories.create!(
      short_title: "SLE",
      title: "Sierra Leone"
    )
    country.categories.create!(
      short_title: "SGP",
      title: "Singapore"
    )
    country.categories.create!(
      short_title: "SVK",
      title: "Slovakia"
    )
    country.categories.create!(
      short_title: "SVN",
      title: "Slovenia"
    )
    country.categories.create!(
      short_title: "SLB",
      title: "Solomon Islands"
    )
    country.categories.create!(
      short_title: "SOM",
      title: "Somalia"
    )
    country.categories.create!(
      short_title: "ZAF",
      title: "South Africa"
    )
    country.categories.create!(
      short_title: "SDS",
      title: "South Sudan"
    )
    country.categories.create!(
      short_title: "ESP",
      title: "Spain"
    )
    country.categories.create!(
      short_title: "LKA",
      title: "Sri Lanka"
    )
    country.categories.create!(
      short_title: "PSE",
      title: "State of Palestine"
    )
    country.categories.create!(
      short_title: "SDN",
      title: "Sudan"
    )
    country.categories.create!(
      short_title: "SUR",
      title: "Suriname"
    )
    country.categories.create!(
      short_title: "SWE",
      title: "Sweden"
    )
    country.categories.create!(
      short_title: "CHE",
      title: "Switzerland"
    )
    country.categories.create!(
      short_title: "SYR",
      title: "Syrian Arab Republic"
    )
    country.categories.create!(
      short_title: "TJK",
      title: "Tajikistan"
    )
    country.categories.create!(
      short_title: "THA",
      title: "Thailand"
    )
    country.categories.create!(
      short_title: "TLS",
      title: "Timor-Leste"
    )
    country.categories.create!(
      short_title: "TGO",
      title: "Togo"
    )
    country.categories.create!(
      short_title: "TON",
      title: "Tonga"
    )
    country.categories.create!(
      short_title: "TTO",
      title: "Trinidad and Tobago"
    )
    country.categories.create!(
      short_title: "TUN",
      title: "Tunisia"
    )
    country.categories.create!(
      short_title: "TUR",
      title: "Türkiye"
    )
    country.categories.create!(
      short_title: "TKM",
      title: "Turkmenistan"
    )
    country.categories.create!(
      short_title: "TUV",
      title: "Tuvalu"
    )
    country.categories.create!(
      short_title: "UGA",
      title: "Uganda"
    )
    country.categories.create!(
      short_title: "UKR",
      title: "Ukraine"
    )
    country.categories.create!(
      short_title: "ARE",
      title: "United Arab Emirates"
    )
    country.categories.create!(
      short_title: "GBR",
      title: "United Kingdom of Great Britain and Northern Ireland"
    )
    country.categories.create!(
      short_title: "TZA",
      title: "United Republic of Tanzania"
    )
    country.categories.create!(
      short_title: "USA",
      title: "United States of America"
    )
    country.categories.create!(
      short_title: "URY",
      title: "Uruguay"
    )
    country.categories.create!(
      short_title: "UZB",
      title: "Uzbekistan"
    )
    country.categories.create!(
      short_title: "VUT",
      title: "Vanuatu"
    )
    country.categories.create!(
      short_title: "VEN",
      title: "Venezuela (Bolivarian Republic of)"
    )
    country.categories.create!(
      short_title: "VNM",
      title: "Viet Nam"
    )
    country.categories.create!(
      short_title: "YEM",
      title: "Yemen"
    )
    country.categories.create!(
      short_title: "ZMB",
      title: "Zambia"
    )
    country.categories.create!(
      short_title: "ZWE",
      title: "Zimbabwe"
    )
    # SDGs
    sdg.categories.create!(
      description: "End poverty in all its forms everywhere",
      title: "No poverty",
      reference: 1,
      short_title: "SDG 1",
      url: ""
    )
    sdg.categories.create!(
      description: "End hunger, achieve food security and improved nutrition and promote sustainable agriculture",
      title: "Zero hunger",
      reference: 2,
      short_title: "SDG 2",
      url: ""
    )
    sdg.categories.create!(
      description: "Ensure healthy lives and promote well-being for all at all ages",
      title: "Good Health and Well-being",
      reference: 3,
      short_title: "SDG 3",
      url: ""
    )
    sdg.categories.create!(
      description: "Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all",
      title: "Quality Education",
      reference: 4,
      short_title: "SDG 4",
      url: ""
    )
    sdg.categories.create!(
      description: "Achieve gender equality and empower all women and girls",
      title: "Gender Equality",
      reference: 5,
      short_title: "SDG 5",
      url: ""
    )
    sdg.categories.create!(
      description: "Ensure availability and sustainable management of water and sanitation for all",
      title: "Clean Water and Sanitation",
      reference: 6,
      short_title: "SDG 6",
      url: ""
    )
    sdg.categories.create!(
      description: "Ensure access to affordable, reliable, sustainable and modern energy for all",
      title: "Affordable and Clean Energy",
      reference: 7,
      short_title: "SDG 7",
      url: ""
    )
    sdg.categories.create!(
      description: "Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all",
      title: "Decent Work and Economic Growth",
      reference: 8,
      short_title: "SDG 8",
      url: ""
    )
    sdg.categories.create!(
      description: "Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation",
      title: "Industry, Innovation and Infrastructure",
      reference: 9,
      short_title: "SDG 9",
      url: ""
    )
    sdg.categories.create!(
      description: "Reduce income inequality within and among countries",
      title: "Reduced Inequalities",
      reference: 10,
      short_title: "SDG 10",
      url: ""
    )
    sdg.categories.create!(
      description: "Make cities and human settlements inclusive, safe, resilient and sustainable",
      title: "Sustainable Cities and Communities",
      reference: 11,
      short_title: "SDG 11",
      url: ""
    )
    sdg.categories.create!(
      description: "Ensure sustainable consumption and production patterns",
      title: "Responsible Consumption and Production",
      reference: 12,
      short_title: "SDG 12",
      url: ""
    )
    sdg.categories.create!(
      description: "Take urgent action to combat climate change and its impacts by regulating emissions and promoting developments in renewable energy",
      title: "Climate Action",
      reference: 13,
      short_title: "SDG 13",
      url: ""
    )
    sdg.categories.create!(
      description: "Conserve and sustainably use the oceans, seas and marine resources for sustainable development",
      title: "Life Below Water",
      reference: 14,
      short_title: "SDG 14",
      url: ""
    )
    sdg.categories.create!(
      description: "Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss",
      title: "Life on Land",
      reference: 15,
      short_title: "SDG 15",
      url: ""
    )
    sdg.categories.create!(
      description: "Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels",
      title: "Peace, Justice and Strong Institutions",
      reference: 16,
      short_title: "SDG 16",
      url: ""
    )
    sdg.categories.create!(
      description: "Strengthen the means of implementation and revitalize the global partnership for sustainable development",
      title: "Partnerships for the Goals",
      reference: 17,
      short_title: "SDG 17",
      url: ""
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
