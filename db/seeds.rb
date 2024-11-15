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
    # Set up user roles and permissions
    Role::Setup.call
    Permission::Setup.call
    RolePermission::Setup.call

    Page.new(title: "Copyright", menu_title: "Copyright").save!
    Page.new(title: "Disclaimer", menu_title: "Disclaimer").save!
    Page.new(title: "Privacy", menu_title: "Privacy").save!
    Page.new(title: "About the Human Rights Monitor", menu_title: "About").save!

    # set up frameworks
    hr = Framework.find_or_create_by!(
      title: "International Human Rights Obligations",
      short_title: "HR",
      has_indicators: false,
      has_measures: true,
      has_response: true
    )

    # Set up taxonomies
    # 1. Global taxonomy
    body = Taxonomy.find_or_create_by!(
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
    FrameworkTaxonomy.find_or_create_by!(
      framework: hr,
      taxonomy: body
    )
    # 2. Global taxonomy
    cycle = Taxonomy.find_or_create_by!(
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
    FrameworkTaxonomy.find_or_create_by!(
      framework: hr,
      taxonomy: cycle
    )
    # 3. Global taxonomy
    country = Taxonomy.find_or_create_by!(
      framework: hr,
      title: "Recommending state",
      tags_measures: false,
      tags_users: false,
      allow_multiple: false,
      priority: 2,
      is_smart: false
    )
    FrameworkTaxonomy.find_or_create_by!(
      framework: hr,
      taxonomy: country
    )

    # 4. Global taxonomy
    issue = Taxonomy.find_or_create_by!(
      framework: hr,
      title: "Human rights issue",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 3,
      is_smart: false
    )
    FrameworkTaxonomy.find_or_create_by!(
      framework: hr,
      taxonomy: issue
    )

    # 5. Global taxonomy
    persons = Taxonomy.find_or_create_by!(
      framework: hr,
      title: "Affected persons",
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 4,
      is_smart: false
    )
    FrameworkTaxonomy.find_or_create_by!(
      framework: hr,
      taxonomy: persons
    )

    # 6. Country specific taxonomy
    org = Taxonomy.find_or_create_by!(
      title: "Government agencies",
      tags_measures: true,
      tags_users: true,
      allow_multiple: true,
      priority: 6,
      is_smart: false
    )

    FrameworkTaxonomy.find_or_create_by!(
      framework: hr,
      taxonomy: org
    )
    # 7. Country specific taxonomy
    smart = Taxonomy.find_or_create_by!(
      title: "SMART criteria",
      is_smart: true,
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 8
    )
    # 8. Country specific taxonomy
    progress = Taxonomy.find_or_create_by!(
      title: "Progress status",
      is_smart: false,
      tags_measures: true,
      tags_users: false,
      allow_multiple: false,
      priority: 7
    )

    # Set up categories
    # SMART categories
    smart.categories.find_or_create_by!(
      title: "Specific",
      short_title: "S",
      reference: "1",
      description: "The action and associated indicators are clear and concrete. They are focused on a particular programme or activity, or a particular aspect of the programme or activity"
    )
    smart.categories.find_or_create_by!(
      title: "Measurable",
      short_title: "M",
      reference: "2",
      description: "The indicators should have a clear unit of measurement, such as delivering an aspect of a programme or activity, percentages, numbers or rates."
    )
    smart.categories.find_or_create_by!(
      title: "Assignable",
      short_title: "A",
      reference: "3",
      description: "An agency is clearly responsible for the action and associated indicators"
    )
    smart.categories.find_or_create_by!(
      title: "Relevant",
      short_title: "R",
      reference: "4",
      description: "The actions should have a clear relationship to its indicators."
    )
    smart.categories.find_or_create_by!(
      title: "Time-Bound",
      short_title: "T",
      reference: "5",
      description: "The action should have a clear completion date. Where a completion date is not available due to the ongoing or progressive nature of the action, the indicators should have clear end dates and be measured at specific points in time to track progress against the action."
    )

    progress.categories.find_or_create_by!(title: "In preparation", reference: "1")
    progress.categories.find_or_create_by!(title: "In progress", reference: "2")
    progress.categories.find_or_create_by!(title: "Completed", reference: "3")

    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    upr = body.categories.find_or_create_by!(
      title: "Human rights council (UPR)",
      short_title: "UPR"
    )
    cycle.categories.find_or_create_by!(
      title: "Universal Periodic Review 2024",
      short_title: "UPR-2024",
      reference: "UPR-2024",
      category: upr
    )
    body.categories.find_or_create_by!(
      title: "International Covenant on Civil and Political Rights",
      short_title: "ICCPR"
    )
    body.categories.find_or_create_by!(
      title: "International Covenant on Economic Social and Cultural Rights",
      short_title: "ICESCR"
    )
    body.categories.find_or_create_by!(
      title: "Committee Against Torture and Other Cruel, Inhuman or Degrading Treatment or Punishment",
      short_title: "CAT"
    )
    body.categories.find_or_create_by!(
      title: "Committee for the Elimination of All Forms of Racial Discrimination",
      short_title: "CERD"
    )
    body.categories.find_or_create_by!(
      title: "Committee for the Elimination of All Forms of Discrimination Against Women",
      short_title: "CEDAW"
    )
    body.categories.find_or_create_by!(
      title: "Committee on the Rights of the Child",
      short_title: "CRC"
    )
    body.categories.find_or_create_by!(
      title: "Committee on the Rights of Persons with Disabilities",
      short_title: "CRPD"
    )
    # Agencies
    org.categories.find_or_create_by!(
      title: "Ministry of Justice",
      short_title: "MoJ"
    )
    org.categories.find_or_create_by!(
      title: "Ministry of Foreign Affairs and Trade",
      short_title: "MFAT"
    )
    org.categories.find_or_create_by!(
      title: "Ministry for Women",
      short_title: "MfW"
    )
    org.categories.find_or_create_by!(
      title: "Ministry of Social Development",
      short_title: "MSD"
    )
    org.categories.find_or_create_by!(
      title: "Whaikaha: Ministry of Disabled People",
      short_title: "Whaikaha"
    )
    org.categories.find_or_create_by!(
      title: "Te Puni Kokiri",
      short_title: "TPK"
    )
    org.categories.find_or_create_by!(
      title: "Ministry of Business, Innovation and Employment",
      short_title: "MBIE"
    )
    org.categories.find_or_create_by!(
      title: "Department of Internal Affairs",
      short_title: "DIA"
    )
    org.categories.find_or_create_by!(
      title: "Department of Corrections",
      short_title: "Corrections"
    )
    org.categories.find_or_create_by!(
      title: "New Zealand Police",
      short_title: "Police"
    )
    org.categories.find_or_create_by!(
      title: "Crown Response Unit",
      short_title: "CRU"
    )
    org.categories.find_or_create_by!(
      title: "Ministry of Housing and Urban Development",
      short_title: "HUD"
    )
    org.categories.find_or_create_by!(
      title: "Ministry of Health",
      short_title: "MoH"
    )
    org.categories.find_or_create_by!(
      title: "Ministry of Education",
      short_title: "MoE"
    )
    org.categories.find_or_create_by!(
      title: "Ministry for the Environment",
      short_title: "MfE"
    )
    org.categories.find_or_create_by!(
      title: "National Emergency Management Agency",
      short_title: "NEMA"
    )
    org.categories.find_or_create_by!(
      title: "Te Puna Aonui",
      short_title: "TPA"
    )
    org.categories.find_or_create_by!(
      title: "Public Service Commission",
      short_title: "PSC"
    )

    # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # TODO level 2 and 3 human rights
    issue.categories.find_or_create_by!(
      title: "Equality and non-discrimination",
      short_title: "Equality"
    )
    issue.categories.find_or_create_by!(
      title: "International cooperation",
      short_title: "Cooperation"
    )
    issue.categories.find_or_create_by!(
      title: "Human rights and environmental issues",
      short_title: "Environment"
    )
    issue.categories.find_or_create_by!(
      title: "Counter-terrorism",
      short_title: "Counter-terrorism"
    )
    issue.categories.find_or_create_by!(
      title: "Economic, social and cultural rights",
      short_title: "ESC rights"
    )
    issue.categories.find_or_create_by!(
      title: "Right to an adequate standard of living",
      short_title: "Standard of living"
    )
    issue.categories.find_or_create_by!(
      title: "Employment rights ",
      short_title: "Employment"
    )
    issue.categories.find_or_create_by!(
      title: "Right to health",
      short_title: "Health"
    )
    issue.categories.find_or_create_by!(
      title: "Right to education",
      short_title: "Education"
    )
    issue.categories.find_or_create_by!(
      title: "Rights of women and girls",
      short_title: "Women & girls"
    )
    issue.categories.find_or_create_by!(
      title: "Rights of children and young people",
      short_title: "Children (rights of)"
    )
    issue.categories.find_or_create_by!(
      title: "Rights of persons with disabilities",
      short_title: "Disabilities (rights)"
    )
    issue.categories.find_or_create_by!(
      title: "Indigenous rights and rights of ethnic minorities",
      short_title: "Indigenous rights"
    )
    issue.categories.find_or_create_by!(
      title: "Rights of refugees, migrants and asylum seekers",
      short_title: "Migrants (rights of)"
    )
    issue.categories.find_or_create_by!(
      title: "Rights of older persons",
      short_title: "Older persons"
    )
    issue.categories.find_or_create_by!(
      title: "National human rights framework",
      short_title: "NHRF"
    )
    issue.categories.find_or_create_by!(
      title: "International instruments",
      short_title: "Intl. instruments"
    )
    issue.categories.find_or_create_by!(
      title: "Human rights and criminal justice",
      short_title: "Criminal justice"
    )
    issue.categories.find_or_create_by!(
      title: "Human trafficking, modern slavery and business and human rights",
      short_title: "Business"
    )
    issue.categories.find_or_create_by!(
      title: "Scope of international obligations",
      short_title: "Intl. obligations"
    )
    issue.categories.find_or_create_by!(
      title: "Inter-State cooperation and development assistance",
      short_title: "Inter-State cooperation"
    )
    issue.categories.find_or_create_by!(
      title: "Human rights education, trainings and awareness raising",
      short_title: "HR education"
    )
    issue.categories.find_or_create_by!(
      title: "Context, statistics, budget, civil society",
      short_title: "Context"
    )
    issue.categories.find_or_create_by!(
      title: "International criminal and humanitarian law",
      short_title: "Intl. law"
    )
    issue.categories.find_or_create_by!(
      title: "Right to self-determination",
      short_title: "Self-determination"
    )
    issue.categories.find_or_create_by!(
      title: "Right to development",
      short_title: "Development"
    )
    issue.categories.find_or_create_by!(
      title: "Right to a remedy",
      short_title: "Remedy"
    )
    issue.categories.find_or_create_by!(
      title: "Human rights and use of mercenaries",
      short_title: "Mercenaries (use of)"
    )
    issue.categories.find_or_create_by!(
      title: "Civil and political rights – general measures of implementation",
      short_title: "Civil & political"
    )
    issue.categories.find_or_create_by!(
      title: "Right to physical and moral integrity",
      short_title: "Integrity"
    )
    issue.categories.find_or_create_by!(
      title: "Liberty and security of the person",
      short_title: "Liberty & security"
    )
    issue.categories.find_or_create_by!(
      title: "Fundamental freedoms",
      short_title: "Freedom"
    )
    issue.categories.find_or_create_by!(
      title: "Administration of justice",
      short_title: "Justice"
    )
    issue.categories.find_or_create_by!(
      title: "Rights related to name, identity, nationality",
      short_title: "Identity"
    )
    issue.categories.find_or_create_by!(
      title: "Right to participation in public affairs and right to vote",
      short_title: "Participation"
    )
    issue.categories.find_or_create_by!(
      title: "Rights related to marriage and family",
      short_title: "Family"
    )
    issue.categories.find_or_create_by!(
      title: "Rights to protection of property, financial credit",
      short_title: "Property"
    )
    issue.categories.find_or_create_by!(
      title: "Cultural rights",
      short_title: "Cultural rights"
    )
    issue.categories.find_or_create_by!(
      title: "Internally displaced persons",
      short_title: "Displaced"
    )
    issue.categories.find_or_create_by!(
      title: "Human rights defenders",
      short_title: "HRD"
    )
    issue.categories.find_or_create_by!(
      title: "International conventions",
      short_title: "Intl. conventions"
    )

    # Affected Persons (http://uhri.ohchr.org/search/annotations)
    persons.categories.find_or_create_by!(
      title: "Children and young people",
      short_title: "Children"
    )
    persons.categories.find_or_create_by!(
      title: "Disappeared persons",
      short_title: "Disappeared"
    )
    persons.categories.find_or_create_by!(
      title: "Indigenous peoples",
      short_title: "Indigenous"
    )
    persons.categories.find_or_create_by!(
      title: "Lesbian, gay, bisexual, transgender and intersex persons",
      short_title: "LGBTI"
    )
    persons.categories.find_or_create_by!(
      title: "Migrants, refugees and asylum seekers",
      short_title: "Migrants"
    )
    persons.categories.find_or_create_by!(
      title: "Minorities / racial, ethnic, linguistic, religious or descent-based groups",
      short_title: "Minorities"
    )
    persons.categories.find_or_create_by!(
      title: "Persons living in poverty",
      short_title: "Poverty"
    )
    persons.categories.find_or_create_by!(
      title: "Persons with disabilities",
      short_title: "Disabilities"
    )
    persons.categories.find_or_create_by!(
      title: "Stateless persons",
      short_title: "Stateless"
    )
    persons.categories.find_or_create_by!(
      title: "Women and girls",
      short_title: "Women"
    )
    persons.categories.find_or_create_by!(
      title: "Pacific people",
      short_title: "Pacific"
    )
    persons.categories.find_or_create_by!(
      title: "Māori",
      short_title: "Māori"
    )
    persons.categories.find_or_create_by!(
      title: "Older persons ",
      short_title: "Older"
    )
    persons.categories.find_or_create_by!(
      title: "Persons experiencing homelessness",
      short_title: "Homelessness"
    )
    persons.categories.find_or_create_by!(
      title: "Persons in slavery/trafficked persons",
      short_title: "Slavery"
    )
    persons.categories.find_or_create_by!(
      title: "Public officials",
      short_title: "Public officials"
    )
    persons.categories.find_or_create_by!(
      title: "Media",
      short_title: "Media"
    )
    persons.categories.find_or_create_by!(
      title: "Non-citizens",
      short_title: "Non-citizens"
    )
    persons.categories.find_or_create_by!(
      title: "Persons deprived of their liberty",
      short_title: "Liberty"
    )
    persons.categories.find_or_create_by!(
      title: "Private security",
      short_title: "Private security"
    )
    persons.categories.find_or_create_by!(
      title: "Mercenaries",
      short_title: "Mercenaries"
    )
    persons.categories.find_or_create_by!(
      title: "Persons living in rural areas",
      short_title: "Rural"
    )
    # Countries
    country.categories.find_or_create_by!(
      short_title: "AFG",
      title: "Afghanistan"
    )
    country.categories.find_or_create_by!(
      short_title: "ALB",
      title: "Albania"
    )
    country.categories.find_or_create_by!(
      short_title: "DZA",
      title: "Algeria"
    )
    country.categories.find_or_create_by!(
      short_title: "AND",
      title: "Andorra"
    )
    country.categories.find_or_create_by!(
      short_title: "AGO",
      title: "Angola"
    )
    country.categories.find_or_create_by!(
      short_title: "ATG",
      title: "Antigua and Barbuda"
    )
    country.categories.find_or_create_by!(
      short_title: "ARG",
      title: "Argentina"
    )
    country.categories.find_or_create_by!(
      short_title: "ARM",
      title: "Armenia"
    )
    country.categories.find_or_create_by!(
      short_title: "AUS",
      title: "Australia"
    )
    country.categories.find_or_create_by!(
      short_title: "AUT",
      title: "Austria"
    )
    country.categories.find_or_create_by!(
      short_title: "AZE",
      title: "Azerbaijan"
    )
    country.categories.find_or_create_by!(
      short_title: "BHS",
      title: "Bahamas"
    )
    country.categories.find_or_create_by!(
      short_title: "BHR",
      title: "Bahrain"
    )
    country.categories.find_or_create_by!(
      short_title: "BGD",
      title: "Bangladesh"
    )
    country.categories.find_or_create_by!(
      short_title: "BRB",
      title: "Barbados"
    )
    country.categories.find_or_create_by!(
      short_title: "BLR",
      title: "Belarus"
    )
    country.categories.find_or_create_by!(
      short_title: "BEL",
      title: "Belgium"
    )
    country.categories.find_or_create_by!(
      short_title: "BLZ",
      title: "Belize"
    )
    country.categories.find_or_create_by!(
      short_title: "BEN",
      title: "Benin"
    )
    country.categories.find_or_create_by!(
      short_title: "BTN",
      title: "Bhutan"
    )
    country.categories.find_or_create_by!(
      short_title: "BOL",
      title: "Bolivia (Plurinational State of)"
    )
    country.categories.find_or_create_by!(
      short_title: "BIH",
      title: "Bosnia and Herzegovina"
    )
    country.categories.find_or_create_by!(
      short_title: "BWA",
      title: "Botswana"
    )
    country.categories.find_or_create_by!(
      short_title: "BRA",
      title: "Brazil"
    )
    country.categories.find_or_create_by!(
      short_title: "BRN",
      title: "Brunei Darussalam"
    )
    country.categories.find_or_create_by!(
      short_title: "BGR",
      title: "Bulgaria"
    )
    country.categories.find_or_create_by!(
      short_title: "BFA",
      title: "Burkina Faso"
    )
    country.categories.find_or_create_by!(
      short_title: "BDI",
      title: "Burundi"
    )
    country.categories.find_or_create_by!(
      short_title: "CPV",
      title: "Cabo Verde"
    )
    country.categories.find_or_create_by!(
      short_title: "KHM",
      title: "Cambodia"
    )
    country.categories.find_or_create_by!(
      short_title: "CMR",
      title: "Cameroon"
    )
    country.categories.find_or_create_by!(
      short_title: "CAN",
      title: "Canada"
    )
    country.categories.find_or_create_by!(
      short_title: "CAF",
      title: "Central African Republic"
    )
    country.categories.find_or_create_by!(
      short_title: "TCD",
      title: "Chad"
    )
    country.categories.find_or_create_by!(
      short_title: "CHL",
      title: "Chile"
    )
    country.categories.find_or_create_by!(
      short_title: "CHN",
      title: "China"
    )
    country.categories.find_or_create_by!(
      short_title: "COL",
      title: "Colombia"
    )
    country.categories.find_or_create_by!(
      short_title: "COM",
      title: "Comoros"
    )
    country.categories.find_or_create_by!(
      short_title: "COG",
      title: "Congo"
    )
    country.categories.find_or_create_by!(
      short_title: "COK",
      title: "Cook Islands"
    )
    country.categories.find_or_create_by!(
      short_title: "CRI",
      title: "Costa Rica"
    )
    country.categories.find_or_create_by!(
      short_title: "CIV",
      title: "Côte d'Ivoire"
    )
    country.categories.find_or_create_by!(
      short_title: "HRV",
      title: "Croatia"
    )
    country.categories.find_or_create_by!(
      short_title: "CUB",
      title: "Cuba"
    )
    country.categories.find_or_create_by!(
      short_title: "CYP",
      title: "Cyprus"
    )
    country.categories.find_or_create_by!(
      short_title: "CZE",
      title: "Czechia"
    )
    country.categories.find_or_create_by!(
      short_title: "PRK",
      title: "Democratic People's Republic of Korea"
    )
    country.categories.find_or_create_by!(
      short_title: "COD",
      title: "Democratic Republic of the Congo"
    )
    country.categories.find_or_create_by!(
      short_title: "DNK",
      title: "Denmark"
    )
    country.categories.find_or_create_by!(
      short_title: "DJI",
      title: "Djibouti"
    )
    country.categories.find_or_create_by!(
      short_title: "DMA",
      title: "Dominica"
    )
    country.categories.find_or_create_by!(
      short_title: "DOM",
      title: "Dominican Republic"
    )
    country.categories.find_or_create_by!(
      short_title: "ECU",
      title: "Ecuador"
    )
    country.categories.find_or_create_by!(
      short_title: "EGY",
      title: "Egypt"
    )
    country.categories.find_or_create_by!(
      short_title: "SLV",
      title: "El Salvador"
    )
    country.categories.find_or_create_by!(
      short_title: "GNQ",
      title: "Equatorial Guinea"
    )
    country.categories.find_or_create_by!(
      short_title: "ERI",
      title: "Eritrea"
    )
    country.categories.find_or_create_by!(
      short_title: "EST",
      title: "Estonia"
    )
    country.categories.find_or_create_by!(
      short_title: "SWZ",
      title: "Eswatini"
    )
    country.categories.find_or_create_by!(
      short_title: "ETH",
      title: "Ethiopia"
    )
    country.categories.find_or_create_by!(
      short_title: "FJI",
      title: "Fiji"
    )
    country.categories.find_or_create_by!(
      short_title: "FIN",
      title: "Finland"
    )
    country.categories.find_or_create_by!(
      short_title: "FRA",
      title: "France"
    )
    country.categories.find_or_create_by!(
      short_title: "GAB",
      title: "Gabon"
    )
    country.categories.find_or_create_by!(
      short_title: "GMB",
      title: "Gambia"
    )
    country.categories.find_or_create_by!(
      short_title: "GEO",
      title: "Georgia"
    )
    country.categories.find_or_create_by!(
      short_title: "DEU",
      title: "Germany"
    )
    country.categories.find_or_create_by!(
      short_title: "GHA",
      title: "Ghana"
    )
    country.categories.find_or_create_by!(
      short_title: "GRC",
      title: "Greece"
    )
    country.categories.find_or_create_by!(
      short_title: "GRD",
      title: "Grenada"
    )
    country.categories.find_or_create_by!(
      short_title: "GTM",
      title: "Guatemala"
    )
    country.categories.find_or_create_by!(
      short_title: "GNB",
      title: "Guinea-Bissau"
    )
    country.categories.find_or_create_by!(
      short_title: "GIN",
      title: "Guinea"
    )
    country.categories.find_or_create_by!(
      short_title: "GUY",
      title: "Guyana"
    )
    country.categories.find_or_create_by!(
      short_title: "HTI",
      title: "Haiti"
    )
    country.categories.find_or_create_by!(
      short_title: "VAT",
      title: "Holy See"
    )
    country.categories.find_or_create_by!(
      short_title: "HND",
      title: "Honduras"
    )
    country.categories.find_or_create_by!(
      short_title: "HUN",
      title: "Hungary"
    )
    country.categories.find_or_create_by!(
      short_title: "ISL",
      title: "Iceland"
    )
    country.categories.find_or_create_by!(
      short_title: "IND",
      title: "India"
    )
    country.categories.find_or_create_by!(
      short_title: "IDN",
      title: "Indonesia"
    )
    country.categories.find_or_create_by!(
      short_title: "IRN",
      title: "Iran (Islamic Republic of)"
    )
    country.categories.find_or_create_by!(
      short_title: "IRQ",
      title: "Iraq"
    )
    country.categories.find_or_create_by!(
      short_title: "IRL",
      title: "Ireland"
    )
    country.categories.find_or_create_by!(
      short_title: "ISR",
      title: "Israel"
    )
    country.categories.find_or_create_by!(
      short_title: "ITA",
      title: "Italy"
    )
    country.categories.find_or_create_by!(
      short_title: "JAM",
      title: "Jamaica"
    )
    country.categories.find_or_create_by!(
      short_title: "JPN",
      title: "Japan"
    )
    country.categories.find_or_create_by!(
      short_title: "JOR",
      title: "Jordan"
    )
    country.categories.find_or_create_by!(
      short_title: "KAZ",
      title: "Kazakhstan"
    )
    country.categories.find_or_create_by!(
      short_title: "KEN",
      title: "Kenya"
    )
    country.categories.find_or_create_by!(
      short_title: "KIR",
      title: "Kiribati"
    )
    country.categories.find_or_create_by!(
      short_title: "KWT",
      title: "Kuwait"
    )
    country.categories.find_or_create_by!(
      short_title: "KGZ",
      title: "Kyrgyzstan"
    )
    country.categories.find_or_create_by!(
      short_title: "LAO",
      title: "Lao People's Democratic Republic"
    )
    country.categories.find_or_create_by!(
      short_title: "LVA",
      title: "Latvia"
    )
    country.categories.find_or_create_by!(
      short_title: "LBN",
      title: "Lebanon"
    )
    country.categories.find_or_create_by!(
      short_title: "LSO",
      title: "Lesotho"
    )
    country.categories.find_or_create_by!(
      short_title: "LBR",
      title: "Liberia"
    )
    country.categories.find_or_create_by!(
      short_title: "LBY",
      title: "Libya"
    )
    country.categories.find_or_create_by!(
      short_title: "LIE",
      title: "Liechtenstein"
    )
    country.categories.find_or_create_by!(
      short_title: "LTU",
      title: "Lithuania"
    )
    country.categories.find_or_create_by!(
      short_title: "LUX",
      title: "Luxembourg"
    )
    country.categories.find_or_create_by!(
      short_title: "MDG",
      title: "Madagascar"
    )
    country.categories.find_or_create_by!(
      short_title: "MWI",
      title: "Malawi"
    )
    country.categories.find_or_create_by!(
      short_title: "MYS",
      title: "Malaysia"
    )
    country.categories.find_or_create_by!(
      short_title: "MDV",
      title: "Maldives"
    )
    country.categories.find_or_create_by!(
      short_title: "MLI",
      title: "Mali"
    )
    country.categories.find_or_create_by!(
      short_title: "MLT",
      title: "Malta"
    )
    country.categories.find_or_create_by!(
      short_title: "MHL",
      title: "Marshall Islands"
    )
    country.categories.find_or_create_by!(
      short_title: "MRT",
      title: "Mauritania"
    )
    country.categories.find_or_create_by!(
      short_title: "MUS",
      title: "Mauritius"
    )
    country.categories.find_or_create_by!(
      short_title: "MEX",
      title: "Mexico"
    )
    country.categories.find_or_create_by!(
      short_title: "FSM",
      title: "Micronesia (Federated States of)"
    )
    country.categories.find_or_create_by!(
      short_title: "MCO",
      title: "Monaco"
    )
    country.categories.find_or_create_by!(
      short_title: "MNG",
      title: "Mongolia"
    )
    country.categories.find_or_create_by!(
      short_title: "MNE",
      title: "Montenegro"
    )
    country.categories.find_or_create_by!(
      short_title: "MAR",
      title: "Morocco"
    )
    country.categories.find_or_create_by!(
      short_title: "MOZ",
      title: "Mozambique"
    )
    country.categories.find_or_create_by!(
      short_title: "MMR",
      title: "Myanmar"
    )
    country.categories.find_or_create_by!(
      short_title: "NAM",
      title: "Namibia"
    )
    country.categories.find_or_create_by!(
      short_title: "NRU",
      title: "Nauru"
    )
    country.categories.find_or_create_by!(
      short_title: "NPL",
      title: "Nepal"
    )
    country.categories.find_or_create_by!(
      short_title: "NLD",
      title: "Netherlands"
    )
    country.categories.find_or_create_by!(
      short_title: "NZL",
      title: "New Zealand"
    )
    country.categories.find_or_create_by!(
      short_title: "NIC",
      title: "Nicaragua"
    )
    country.categories.find_or_create_by!(
      short_title: "NER",
      title: "Niger"
    )
    country.categories.find_or_create_by!(
      short_title: "NGA",
      title: "Nigeria"
    )
    country.categories.find_or_create_by!(
      short_title: "NIU",
      title: "Niue"
    )
    country.categories.find_or_create_by!(
      short_title: "MKD",
      title: "North Macedonia"
    )
    country.categories.find_or_create_by!(
      short_title: "NOR",
      title: "Norway"
    )
    country.categories.find_or_create_by!(
      short_title: "OMN",
      title: "Oman"
    )
    country.categories.find_or_create_by!(
      short_title: "PAK",
      title: "Pakistan"
    )
    country.categories.find_or_create_by!(
      short_title: "PLW",
      title: "Palau"
    )
    country.categories.find_or_create_by!(
      short_title: "PAN",
      title: "Panama"
    )
    country.categories.find_or_create_by!(
      short_title: "PNG",
      title: "Papua New Guinea"
    )
    country.categories.find_or_create_by!(
      short_title: "PRY",
      title: "Paraguay"
    )
    country.categories.find_or_create_by!(
      short_title: "PER",
      title: "Peru"
    )
    country.categories.find_or_create_by!(
      short_title: "PHL",
      title: "Philippines"
    )
    country.categories.find_or_create_by!(
      short_title: "POL",
      title: "Poland"
    )
    country.categories.find_or_create_by!(
      short_title: "PRT",
      title: "Portugal"
    )
    country.categories.find_or_create_by!(
      short_title: "QAT",
      title: "Qatar"
    )
    country.categories.find_or_create_by!(
      short_title: "KOR",
      title: "Republic of Korea"
    )
    country.categories.find_or_create_by!(
      short_title: "MDA",
      title: "Republic of Moldova"
    )
    country.categories.find_or_create_by!(
      short_title: "ROU",
      title: "Romania"
    )
    country.categories.find_or_create_by!(
      short_title: "RUS",
      title: "Russian Federation"
    )
    country.categories.find_or_create_by!(
      short_title: "RWA",
      title: "Rwanda"
    )
    country.categories.find_or_create_by!(
      short_title: "KNA",
      title: "Saint Kitts and Nevis"
    )
    country.categories.find_or_create_by!(
      short_title: "LCA",
      title: "Saint Lucia"
    )
    country.categories.find_or_create_by!(
      short_title: "VCT",
      title: "Saint Vincent and the Grenadines"
    )
    country.categories.find_or_create_by!(
      short_title: "WSM",
      title: "Samoa"
    )
    country.categories.find_or_create_by!(
      short_title: "SMR",
      title: "San Marino"
    )
    country.categories.find_or_create_by!(
      short_title: "STP",
      title: "São Tomé and Principe"
    )
    country.categories.find_or_create_by!(
      short_title: "SAU",
      title: "Saudi Arabia"
    )
    country.categories.find_or_create_by!(
      short_title: "SEN",
      title: "Senegal"
    )
    country.categories.find_or_create_by!(
      short_title: "SRB",
      title: "Serbia"
    )
    country.categories.find_or_create_by!(
      short_title: "SYC",
      title: "Seychelles"
    )
    country.categories.find_or_create_by!(
      short_title: "SLE",
      title: "Sierra Leone"
    )
    country.categories.find_or_create_by!(
      short_title: "SGP",
      title: "Singapore"
    )
    country.categories.find_or_create_by!(
      short_title: "SVK",
      title: "Slovakia"
    )
    country.categories.find_or_create_by!(
      short_title: "SVN",
      title: "Slovenia"
    )
    country.categories.find_or_create_by!(
      short_title: "SLB",
      title: "Solomon Islands"
    )
    country.categories.find_or_create_by!(
      short_title: "SOM",
      title: "Somalia"
    )
    country.categories.find_or_create_by!(
      short_title: "ZAF",
      title: "South Africa"
    )
    country.categories.find_or_create_by!(
      short_title: "SDS",
      title: "South Sudan"
    )
    country.categories.find_or_create_by!(
      short_title: "ESP",
      title: "Spain"
    )
    country.categories.find_or_create_by!(
      short_title: "LKA",
      title: "Sri Lanka"
    )
    country.categories.find_or_create_by!(
      short_title: "PSE",
      title: "State of Palestine"
    )
    country.categories.find_or_create_by!(
      short_title: "SDN",
      title: "Sudan"
    )
    country.categories.find_or_create_by!(
      short_title: "SUR",
      title: "Suriname"
    )
    country.categories.find_or_create_by!(
      short_title: "SWE",
      title: "Sweden"
    )
    country.categories.find_or_create_by!(
      short_title: "CHE",
      title: "Switzerland"
    )
    country.categories.find_or_create_by!(
      short_title: "SYR",
      title: "Syrian Arab Republic"
    )
    country.categories.find_or_create_by!(
      short_title: "TJK",
      title: "Tajikistan"
    )
    country.categories.find_or_create_by!(
      short_title: "THA",
      title: "Thailand"
    )
    country.categories.find_or_create_by!(
      short_title: "TLS",
      title: "Timor-Leste"
    )
    country.categories.find_or_create_by!(
      short_title: "TGO",
      title: "Togo"
    )
    country.categories.find_or_create_by!(
      short_title: "TON",
      title: "Tonga"
    )
    country.categories.find_or_create_by!(
      short_title: "TTO",
      title: "Trinidad and Tobago"
    )
    country.categories.find_or_create_by!(
      short_title: "TUN",
      title: "Tunisia"
    )
    country.categories.find_or_create_by!(
      short_title: "TUR",
      title: "Türkiye"
    )
    country.categories.find_or_create_by!(
      short_title: "TKM",
      title: "Turkmenistan"
    )
    country.categories.find_or_create_by!(
      short_title: "TUV",
      title: "Tuvalu"
    )
    country.categories.find_or_create_by!(
      short_title: "UGA",
      title: "Uganda"
    )
    country.categories.find_or_create_by!(
      short_title: "UKR",
      title: "Ukraine"
    )
    country.categories.find_or_create_by!(
      short_title: "ARE",
      title: "United Arab Emirates"
    )
    country.categories.find_or_create_by!(
      short_title: "GBR",
      title: "United Kingdom of Great Britain and Northern Ireland"
    )
    country.categories.find_or_create_by!(
      short_title: "TZA",
      title: "United Republic of Tanzania"
    )
    country.categories.find_or_create_by!(
      short_title: "USA",
      title: "United States of America"
    )
    country.categories.find_or_create_by!(
      short_title: "URY",
      title: "Uruguay"
    )
    country.categories.find_or_create_by!(
      short_title: "UZB",
      title: "Uzbekistan"
    )
    country.categories.find_or_create_by!(
      short_title: "VUT",
      title: "Vanuatu"
    )
    country.categories.find_or_create_by!(
      short_title: "VEN",
      title: "Venezuela (Bolivarian Republic of)"
    )
    country.categories.find_or_create_by!(
      short_title: "VNM",
      title: "Viet Nam"
    )
    country.categories.find_or_create_by!(
      short_title: "YEM",
      title: "Yemen"
    )
    country.categories.find_or_create_by!(
      short_title: "ZMB",
      title: "Zambia"
    )
    country.categories.find_or_create_by!(
      short_title: "ZWE",
      title: "Zimbabwe"
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
