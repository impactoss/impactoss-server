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
    cluster = Taxonomy.create!(
      title: "Thematic cluster",
      framework: hr,
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 5,
      is_smart: false,
      groups_measures_default: 1
    )
    FrameworkTaxonomy.create!(
      framework: hr,
      taxonomy: cluster
    )

    # 7. Country specific taxonomy
    org = Taxonomy.create!(
      title: "Organisation",
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
    # 8. Country specific taxonomy
    smart = Taxonomy.create!(
      title: "SMART criteria",
      is_smart: true,
      tags_measures: true,
      tags_users: false,
      allow_multiple: true,
      priority: 8
    )
    # 9. Country specific taxonomy
    progress = Taxonomy.create!(
      title: "Progress status",
      is_smart: false,
      tags_measures: true,
      tags_users: false,
      allow_multiple: false,
      priority: 7
    )

    # Set up categories
    # SMART categories
    smart.categories.create!(title: "Specific", short_title: "S")
    smart.categories.create!(title: "Measurable", short_title: "M")
    smart.categories.create!(title: "Assignable", short_title: "A")
    smart.categories.create!(title: "Result-oriented", short_title: "R")
    smart.categories.create!(title: "Timebound", short_title: "T")

    progress.categories.create!(title: "In preparation", reference: "1")
    progress.categories.create!(title: "In progress", reference: "2")
    progress.categories.create!(title: "Completed", reference: "3")

    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    body.categories.create!(
      title: "Universal Periodic Review",
      short_title: "UPR"
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
      title: "Convention Against Torture and Other Cruel, Inhuman or Degrading Treatment or Punishment",
      short_title: "CAT"
    )
    body.categories.create!(
      title: "Convention for the Elimination of All Forms of Racial Discrimination",
      short_title: "CERD"
    )
    body.categories.create!(
      title: "Convention for the Elimination of All Forms of Discrimination Against Women",
      short_title: "CEDAW"
    )
    body.categories.create!(
      title: "Convention on the Rights of the Child",
      short_title: "CRC"
    )
    body.categories.create!(
      title: "Convention on the Rights of Persons with Disabilities",
      short_title: "CRPD"
    )
    # Human Rights Issues
    org.categories.create!(
      title: "Ministry of Justice",
      short_title: "MOJ"
    )
    org.categories.create!(
      title: "Ministry of Foreign Affairs and Trade",
      short_title: "MFAT"
    )
    org.categories.create!(
      title: "Ministry for Women",
      short_title: "MfW"
    )
    org.categories.create!(
      title: "Ministry of Social Development",
      short_title: "MSD"
    )
    org.categories.create!(
      title: "Te Whaikaha Ministry of Disabled People",
      short_title: "Whaikaha"
    )
    org.categories.create!(
      title: "Te Puni Kokiri Ministry of Maori Development",
      short_title: "TPK"
    )
    org.categories.create!(
      title: "Statistics New Zealand",
      short_title: "Stats NZ"
    )

    # Thematic Clusters
    cluster.categories.create!(
    	title: "CAT Ratification",
    	short_title: "CAT"
    )
    cluster.categories.create!(
    	title: "Climate change",
    	short_title: "Climate"
    )
    cluster.categories.create!(
    	title: "Combat sexual exploitation and abuse",
    	short_title: "Abuse"
    )
    cluster.categories.create!(
    	title: "Combat violence against children",
    	short_title: "Children"
    )
    cluster.categories.create!(
    	title: "Combat violence against women",
    	short_title: "Women"
    )
    cluster.categories.create!(
    	title: "Countering violent extremism/terrorism",
    	short_title: "Extremism/terrorism"
    )
    cluster.categories.create!(
    	title: "Education",
    	short_title: "Education"
    )
    cluster.categories.create!(
    	title: "Equality and non-discrimination in the criminal justice system",
    	short_title: "Equality"
    )
    cluster.categories.create!(
    	title: "Families and young persons",
    	short_title: "Families"
    )
    cluster.categories.create!(
    	title: "Gender equality",
    	short_title: "Gender"
    )
    cluster.categories.create!(
    	title: "Poverty",
    	short_title: "Poverty"
    )
    cluster.categories.create!(
    	title: "Reduce child poverty",
    	short_title: "Child poverty"
    )
    cluster.categories.create!(
    	title: "Sea level rise",
    	short_title: "Sea level rise"
    )
    cluster.categories.create!(
    	title: "Strengthen institutional capacity to serve the public interest with competence and justice",
    	short_title: "Inst. capacity"
    )
    cluster.categories.create!(
    	title: "Violence, abuse and neglect",
    	short_title: "Violence"
    )

    # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # TODO level 2 and 3 human rights
    issue.categories.create!(
      title: "Scope of international obligations",
      short_title: "Intl. obligations",
      reference: "A1"
    )
    issue.categories.create!(
      title: "Cooperation with human rights mechanisms and institutions",
      short_title: "Cooperation ",
      reference: "A2"
    )
    issue.categories.create!(
      title: "Inter-State cooperation and development assistance",
      short_title: "Inter-State cooperation",
      reference: "A3"
    )
    issue.categories.create!(
      title: "Legal, institutional and policy framework",
      short_title: "Framework",
      reference: "A4"
    )
    issue.categories.create!(
      title: "Human rights education, trainings and awareness raising",
      short_title: "HR education",
      reference: "A5"
    )
    issue.categories.create!(
      title: "Context, statistics, budget, civil society",
      short_title: "Context",
      reference: "A6"
    )
    issue.categories.create!(
      title: "International criminal and humanitarian law",
      short_title: "Intl. law",
      reference: "B1"
    )
    issue.categories.create!(
      title: "Right to self-determination",
      short_title: "Self-determination",
      reference: "B2"
    )
    issue.categories.create!(
      title: "Equality and non-discrimination",
      short_title: "Equality",
      reference: "B3"
    )
    issue.categories.create!(
      title: "Right to development",
      short_title: "Development",
      reference: "B4"
    )
    issue.categories.create!(
      title: "Right to a remedy",
      short_title: "Remedy",
      reference: "B5"
    )
    issue.categories.create!(
      title: "Business and human rights",
      short_title: "Business",
      reference: "B6"
    )
    issue.categories.create!(
      title: "Human rights and environmental issues",
      short_title: "Environment",
      reference: "B7"
    )
    issue.categories.create!(
      title: "Human rights and counter-terrorism",
      short_title: "Counter-terrorism",
      reference: "B8"
    )
    issue.categories.create!(
      title: "Human rights and use of mercenaries",
      short_title: "Mercenaries",
      reference: "B9"
    )
    issue.categories.create!(
      title: "Civil and political rights - general measures of implementation",
      short_title: "Civil & political",
      reference: "D1"
    )
    issue.categories.create!(
      title: "Right to physical and moral integrity",
      short_title: "Integrity",
      reference: "D2"
    )
    issue.categories.create!(
      title: "Liberty and security of the person",
      short_title: "Liberty",
      reference: "D3"
    )
    issue.categories.create!(
      title: "Fundamental freedoms",
      short_title: "Freedoms",
      reference: "D4"
    )
    issue.categories.create!(
      title: "Administration of justice",
      short_title: "Justice",
      reference: "D5"
    )
    issue.categories.create!(
      title: "Rights related to name, identity, nationality",
      short_title: "Identity",
      reference: "D6"
    )
    issue.categories.create!(
      title: "Right to participation in public affairs and right to vote",
      short_title: "Participation",
      reference: "D7"
    )
    issue.categories.create!(
      title: "Rights related to marriage and family",
      short_title: "Family",
      reference: "D8"
    )
    issue.categories.create!(
      title: "Economic, social and cultural rights - general measures of implementation",
      short_title: "Economic, social & cultural",
      reference: "E1"
    )
    issue.categories.create!(
      title: "Right to an adequate standard of living",
      short_title: "Standard of living",
      reference: "E2"
    )
    issue.categories.create!(
      title: "Labour rights",
      short_title: "Labour rights",
      reference: "E3"
    )
    issue.categories.create!(
      title: "Right to health",
      short_title: "Health",
      reference: "E4"
    )
    issue.categories.create!(
      title: "Right to education",
      short_title: "Education",
      reference: "E5"
    )
    issue.categories.create!(
      title: "Rights to protection of property, financial credit",
      short_title: "Property",
      reference: "E6"
    )
    issue.categories.create!(
      title: "Cultural rights",
      short_title: "Cultural rights",
      reference: "E7"
    )
    issue.categories.create!(
      title: "Women",
      short_title: "Women",
      reference: "F1"
    )
    issue.categories.create!(
      title: "Children",
      short_title: "Children",
      reference: "F3"
    )
    issue.categories.create!(
      title: "Persons with disabilities",
      short_title: "Disabilities",
      reference: "F4"
    )
    issue.categories.create!(
      title: "Members of minorities",
      short_title: "Minorities",
      reference: "G1"
    )
    issue.categories.create!(
      title: "Indigenous peoples",
      short_title: "Indigenous",
      reference: "G3"
    )
    issue.categories.create!(
      title: "Migrants",
      short_title: "Migrants",
      reference: "G4"
    )
    issue.categories.create!(
      title: "Refugees and asylum seekers",
      short_title: "Refugees",
      reference: "G5"
    )
    issue.categories.create!(
      title: "Internally displaced persons",
      short_title: "Displaced",
      reference: "G5"
    )
    issue.categories.create!(
      title: "Human rights defenders",
      short_title: "HRD",
      reference: "H1"
    )

    # Affected Persons (http://uhri.ohchr.org/search/annotations)
    persons.categories.create!(
      title: "Children",
      short_title: "Children"
    )
    persons.categories.create!(
      title: "Children in street situations",
      short_title: "CSS"
    )
    persons.categories.create!(
      title: "Disappeared persons",
      short_title: "Disappeared"
    )
    persons.categories.create!(
      title: "Educational staff",
      short_title: "Edu"
    )
    persons.categories.create!(
      title: "General",
      short_title: "General"
    )
    persons.categories.create!(
      title: "Girls",
      short_title: "Girls"
    )
    persons.categories.create!(
      title: "Human rights defenders",
      short_title: "HRD"
    )
    persons.categories.create!(
      title: "Indigenous peoples",
      short_title: "Indigenous"
    )
    persons.categories.create!(
      title: "Internally displaced persons",
      short_title: "IDP"
    )
    persons.categories.create!(
      title: "Judges, lawyers and prosecutors",
      short_title: "JLP"
    )
    persons.categories.create!(
      title: "Law enforcement/police officials",
      short_title: "Law"
    )
    persons.categories.create!(
      title: "Lesbian, gay, bisexual and transgender and intersex persons",
      short_title: "LGBTI"
    )
    persons.categories.create!(
      title: "Media",
      short_title: "Media"
    )
    persons.categories.create!(
      title: "Medical staff",
      short_title: "Medical"
    )
    persons.categories.create!(
      title: "Mercenaries",
      short_title: "Mercenaries"
    )
    persons.categories.create!(
      title: "Migrants",
      short_title: "Migrants"
    )
    persons.categories.create!(
      title: "Military staff",
      short_title: "Military"
    )
    persons.categories.create!(
      title: "Minorities / racial, ethnic, linguistic, religious or descent-based groups",
      short_title: "Minorities"
    )
    persons.categories.create!(
      title: "Non-citizens",
      short_title: "Non-citizens"
    )
    persons.categories.create!(
      title: "Older persons",
      short_title: "Older persons"
    )
    persons.categories.create!(
      title: "Persons affected by armed conflict",
      short_title: "Armed conflict"
    )
    persons.categories.create!(
      title: "Persons deprived of their liberty",
      short_title: "Liberty"
    )
    persons.categories.create!(
      title: "Persons living in poverty",
      short_title: "Poverty"
    )
    persons.categories.create!(
      title: "Persons living in rural areas",
      short_title: "Rural"
    )
    persons.categories.create!(
      title: "Persons living with HIV/AIDS",
      short_title: "HIV/AIDS"
    )
    persons.categories.create!(
      title: "Persons with disabilities",
      short_title: "Disabilities"
    )
    persons.categories.create!(
      title: "Prison officials",
      short_title: "Prison officials"
    )
    persons.categories.create!(
      title: "Private security",
      short_title: "Private security"
    )
    persons.categories.create!(
      title: "Public officials",
      short_title: "Public officials"
    )
    persons.categories.create!(
      title: "Refugees & asylum seekers",
      short_title: "Refugees"
    )
    persons.categories.create!(
      title: "Rural women",
      short_title: "Rural women"
    )
    persons.categories.create!(
      title: "Social workers",
      short_title: "Social workers"
    )
    persons.categories.create!(
      title: "Stateless persons",
      short_title: "Stateless"
    )
    persons.categories.create!(
      title: "Vulnerable persons/groups",
      short_title: "Vulnerable"
    )
    persons.categories.create!(
      title: "Women",
      short_title: "Women"
    )
    persons.categories.create!(
      title: "Youth",
      short_title: "Youth"
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
  end

  def development_seeds!
    nil unless User.count.zero?
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
