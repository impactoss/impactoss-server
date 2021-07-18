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

    # set up frameworks ########################################################
    hr = Framework.new(
        title: 'International Human Rights Obligations',
        short_title: 'HR',
        has_indicators: false,
        has_measures: true,
        has_response: true,
      )
    hr.save!

    sdsfw = Framework.new(
        title: 'Strategy for the Development of Samoa',
        short_title: 'SDS',
        has_indicators: true,
        has_measures: true,
        has_response: false,
      )
    sdsfw.save!
    sdgfw = Framework.new(
        title: 'Sustainable Debelopment Goals',
        short_title: 'SDGs',
        has_indicators: true,
        has_measures: true,
        has_response: false,
      )
    sdgfw.save!

    # Set up taxonomies ########################################################
    # 1. Global taxonomy
    body = FactoryGirl.create(
        :taxonomy,
        framework:hr,
        title: 'Human rights body',
        tags_measures: false,
        tags_users: false,
        allow_multiple: false,
        has_manager: true,
        priority: 11,
        groups_recommendations_default: 1
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:body,
    )
    # 2. Global taxonomy
    cycle = FactoryGirl.create(
        :taxonomy,
        framework:hr,
        title: 'Cycle',
        tags_measures: false,
        tags_users: false,
        allow_multiple: false,
        priority: 12,
        groups_recommendations_default: 2,
        parent_id: 1, # referencing hr body
        has_date: true
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:cycle,
    )

    # 3. Global taxonomy
    right = FactoryGirl.create(
        :taxonomy,
        framework:hr,
        title: 'Human rights issue',
        tags_measures: true,
        tags_users: false,
        allow_multiple: true,
        priority: 51
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:right,
    )

    # 4. Global taxonomy
    persons = FactoryGirl.create(
        :taxonomy,
        framework:hr,
        title: 'Affected persons',
        tags_measures: true,
        tags_users: false,
        allow_multiple: true,
        priority: 52
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:persons,
    )
    # 5. Country specific taxonomy
    cluster = FactoryGirl.create(
        :taxonomy,
        title: 'Thematic cluster',
        tags_measures: true,
        tags_users: false,
        allow_multiple: true,
        priority: 100,
        groups_measures_default: 1
      )

    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:cluster,
    )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:sdgfw,
      taxonomy:cluster,
    )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:sdsfw,
      taxonomy:cluster,
    )

    # 6. Samoa specific taxonomy
    org = FactoryGirl.create(
        :taxonomy,
        title: 'Organisation',
        tags_measures: true,
        tags_users: true,
        allow_multiple: true,
        priority: 41
      )

    # 7. Global taxonomy
    sdg = FactoryGirl.create(
        :taxonomy,
        framework:sdgfw,
        title: 'SDGs',
        has_manager: true,
        allow_multiple: true,
        priority: 31
      )

    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:sdg,
    )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:sdgfw,
      taxonomy:sdg,
    )

    # 8. Progress
    progress = FactoryGirl.create(
        :taxonomy,
        title: 'Progress status',
        tags_measures: true,
        allow_multiple: false,
        priority: 42
      )
    # 9. SDS priority area
    priorityArea = FactoryGirl.create(
        :taxonomy,
        framework:sdsfw,
        title: 'Priority area',
        tags_measures: false,
        allow_multiple: false,
        priority: 21
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:sdsfw,
      taxonomy:priorityArea,
    )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:outcome,
    )

    # 10. SDS key outcome
    outcome = FactoryGirl.create(
        :taxonomy,
        framework:sdsfw,
        title: 'Key outcome',
        tags_measures: false,
        allow_multiple: true,
        priority: 22,
        parent_id: 9
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:sdsfw,
      taxonomy:outcome,
    )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:outcome,
    )

    # 11. Source
    source = FactoryGirl.create(
        :taxonomy,
        framework:hr,
        title: 'Recommendation source',
        tags_measures: false,
        allow_multiple: false,
        priority: 10
      )
    FactoryGirl.create(
      :framework_taxonomy,
      framework:hr,
      taxonomy:source,
    )

    # Set up categories ########################################################
    # sds priority areas
    sds1 = FactoryGirl.create(
        :category,
        taxonomy:priorityArea,
        title:'Economic',
        reference: '1'
      )
    sds2 = FactoryGirl.create(
        :category,
        taxonomy:priorityArea,
        title:'Social',
        reference: '2'
      )
    sds3 = FactoryGirl.create(
        :category,
        taxonomy:priorityArea,
        title:'Infrastructure',
        reference: '3'
      )
    sds4 = FactoryGirl.create(
        :category,
        taxonomy:priorityArea,
        title:'Environment',
        reference: '4'
      )
    # sds key outcomes
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Macroeconomic Resilience Increased and Sustained',
        reference: '1',
        parent:sds1
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Agriculture and Fisheries Productivity Increased',
        reference: '2',
        parent:sds1
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Export Products Increased',
        reference: '3',
        parent:sds1
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Tourism Development and Performance Improved',
        reference: '4',
        parent:sds1
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Participation of Private Sector in Development Enhanced',
        reference: '5',
        parent:sds1
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'A Healthy Samoa and Well-being Promoted',
        reference: '6',
        parent:sds2
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Quality Education and Training Improved',
        reference: '7',
        parent:sds2
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Social Institutions Strengthened - Community Development Enhanced',
        reference: '8a',
        parent:sds2
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Social Institutions Strengthened - Community Safety Improved',
        reference: '8b',
        parent:sds2
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Access to Clean Water and Sanitation Sustained',
        reference: '9',
        parent:sds3
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Transport Systems and Networks Improved',
        reference: '10',
        parent:sds3
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Improved and Affordable Country Wide ICT Connectivity',
        reference: '11',
        parent:sds3
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Quality Energy Supply',
        reference: '12',
        parent:sds3
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Environmental Resilience Improved',
        reference: '13',
        parent:sds4
      )
    FactoryGirl.create(
        :category,
        taxonomy:outcome,
        title:'Climate and Disaster Resilience',
        reference: '14',
        parent:sds4
      )
    # Human Rights Bodies http://www.ohchr.org/EN/HRBodies/Pages/HumanRightsBodies.aspx
    hr1 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Universal Periodic Review',
        short_title:'UPR',
        reference:'UPR'
      )
    hr2 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Human Rights Committee',
        short_title:'CCPR',
        reference:'CCPR'
      )
    hr3 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Economic, Social and Cultural Rights',
        short_title:'CESCR',
        reference:'CESCR'
      )
    hr4= FactoryGirl.create(
      :category,
      taxonomy:body,
      title:'Committee on the Elimination of Discrimination against Women',
      short_title:'CEDAW',
      reference:'CEDAW'
    )
    hr5 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee against Torture',
        short_title:'CAT',
        reference:'CAT'
      )
    hr6 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Rights of the Child',
        short_title:'CRC',
        reference:'CRC'
      )
    hr7 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on the Rights of Persons with Disabilities',
        short_title:'CRPD',
        reference:'CRPD'
      )
    hr8 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Committee on Enforced Disappearances',
        short_title:'CED',
        reference:'CED'
      )
    hr9 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Working Group on discrimination against women in law and in practice',
        short_title:'WGDAW',
        reference:'WGDAW'
      )
    hr10 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'National Human Rights Institution (Ombudsman)',
        short_title:'NHRI',
        reference:'NHRI'
      )
    hr11 = FactoryGirl.create(
        :category,
        taxonomy:body,
        title:'Samoa Law Reform Commission',
        short_title:'SLRC',
        reference:'SLRC'
      )
    # HR body cycles
    FactoryGirl.create(
        :category,
    		taxonomy:cycle,
    		title:"UPR 1st cycle",
    		short_title:"UPR 1",
    		description:"Recommendations following Samoa's First Universal Periodic Review in 2011",
    		url:"https://documents-dds-ny.un.org/doc/UNDOC/GEN/G11/146/32/PDF/G1114632.pdf?OpenElement",
    		draft:true,
    		user_only:false,
    		parent:hr1
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"UPR 2nd cycle",
    		short_title:"UPR 2",
    		draft:false,
    		user_only:false,
    		parent:hr1
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"UPR 3rd cycle",
    		short_title:"UPR 3",
    		draft:true,
    		user_only:false,
    		parent:hr1
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"ICCPR Articles",
    		short_title:"ICCPR Articles",
    		draft:false,
    		user_only:false,
    		parent:hr2
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"ICESCR Articles",
    		short_title:"ICESCR Articles",
    		draft:false,
    		user_only:false,
    		parent:hr3
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CEDAW Articles",
    		short_title:"CEDAW Articles",
    		draft:false,
    		user_only:false,
    		parent:hr4
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CEDAW General Recommendations",
    		short_title:"CEDAW-GR",
    		draft:true,
    		user_only:false,
    		parent:hr4
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CEDAW 1-3 Periodic Report",
    		short_title:"CEDAW 1-3",
    		description:"Combined initial, second and third report on CEDAW",
    		draft:true,
    		user_only:false,
    		parent:hr4
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CEDAW 4-5 Periodic Report",
    		short_title:"CEDAW 4-5",
    		draft:true,
    		user_only:false,
    		parent:hr4
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CEDAW 6th Periodic Report",
    		short_title:"6th Cycle",
    		draft:false,
    		user_only:false,
    		parent:hr4
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CAT Articles",
    		short_title:"CAT Articles",
    		draft:false,
    		user_only:false,
    		parent:hr5
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CRC Articles",
    		short_title:"CRC Articles",
    		draft:false,
    		user_only:false,
    		parent:hr6
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CRC cycle 2-4",
    		short_title:"CRC 2-4",
    		draft:false,
    		parent:hr6
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CRPD Articles",
    		short_title:"CRPD Articles",
    		draft:false,
    		user_only:false,
    		parent:hr7
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"CPPED Articles",
    		short_title:"CPPED Articles",
    		draft:false,
    		user_only:false,
    		parent:hr8
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"WGDAW all",
    		short_title:"WGDAW all",
    		draft:false,
    		user_only:false,
    		parent:hr9
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"NHRI 2015-2019",
    		short_title:"NHRI 2015-2019",
    		draft:false,
    		user_only:false,
    		parent:hr10
      )

    FactoryGirl.create(
        :category,
        taxonomy:cycle,
    		title:"SLRC 2016",
    		short_title:"SLRC 2016",
    		draft:false,
    		user_only:false,
    		parent:hr11
      )
    # # Human Rights Issues (level 2 http://uhri.ohchr.org/search/guide)
    # # TODO level 2 and 3 human rights
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Scope of international obligations',
        short_title:'Int. obligations',
        reference:'A1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Cooperation with human rights mechanisms and institutions',
        short_title:'Cooperation ',
        reference:'A2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Inter-State cooperation & development assistance',
        short_title:'Inter-State cooperation',
        reference:'A3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Legal, institutional and policy framework',
        short_title:'Framework',
        reference:'A4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights education, trainings and awareness raising',
        short_title:'HR education',
        reference:'A5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Context, statistics, budget, civil society',
        short_title:'Context',
        reference:'A6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'International criminal and humanitarian law',
        short_title:'Int. law',
        reference:'B1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to self-determination',
        short_title:'Self-determination',
        reference:'B2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Equality and non-discrimination',
        short_title:'Equality',
        reference:'B3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to development',
        short_title:'Development',
        reference:'B4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to a remedy',
        short_title:'Remedy',
        reference:'B5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Business & Human Rights',
        short_title:'Business',
        reference:'B6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights and environmental issues',
        short_title:'Environment',
        reference:'B7',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights & counter-terrorism',
        short_title:'Counter-terrorism',
        reference:'B8',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights & use of mercenaries',
        short_title:'Mercenaries',
        reference:'B9',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Civil & political rights - general measures of implementation',
        short_title:'Civil & political',
        reference:'D1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to physical and moral integrity',
        short_title:'Integrity',
        reference:'D2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Liberty and security of the person',
        short_title:'Liberty',
        reference:'D3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Fundamental freedoms',
        short_title:'Freedoms',
        reference:'D4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Administration of justice',
        short_title:'Justice',
        reference:'D5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Rights related to name, identity, nationality',
        short_title:'Identity',
        reference:'D6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to participation in public affairs and right to vote',
        short_title:'Participation',
        reference:'D7',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Rights related to marriage & family',
        short_title:'Family',
        reference:'D8',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Economic, social & cultural rights - general measures of implementation',
        short_title:'Economic, social & cultural',
        reference:'E1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to an adequate standard of living',
        short_title:'Standard of living',
        reference:'E2',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Labour rights',
        short_title:'Labour rights',
        reference:'E3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to health',
        short_title:'Health',
        reference:'E4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Right to education',
        short_title:'Education',
        reference:'E5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Rights to protection of property; financial credit',
        short_title:'Property',
        reference:'E6',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Cultural rights',
        short_title:'Cultural rights',
        reference:'E7',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Women',
        short_title:'Women',
        reference:'F1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Children',
        short_title:'Children',
        reference:'F3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Persons with disabilities',
        short_title:'Persons with disabilities',
        reference:'F4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Members of minorities',
        short_title:'Minorities',
        reference:'G1',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Indigenous peoples',
        short_title:'Indigenous peoples',
        reference:'G3',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Migrants',
        short_title:'Migrants',
        reference:'G4',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Refugees & asylum seekers',
        short_title:'Refugees',
        reference:'G5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Internally displaced persons',
        short_title:'Internally displaced',
        reference:'G5',
        description:'',
        url:''
      )
    FactoryGirl.create(
        :category,
        taxonomy:right,
        title:'Human rights defenders',
        short_title:'HR defenders',
        reference:'H1',
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
      # Sources
      FactoryGirl.create(
          :category,
          taxonomy:source,
          title:'HR Convention Articles',
          short_title:'Convention'
        )
      FactoryGirl.create(
          :category,
          taxonomy:source,
          title:'International recommendations',
          short_title:'Internatl.'
        )
      FactoryGirl.create(
          :category,
          taxonomy:source,
          title:'National recommendations',
          short_title:'National'
        )
      # progress
      FactoryGirl.create(
          :category,
          taxonomy:progress,
          title:'Ongoing',
          short_title:'Ongoing'
        )
      # progress
      FactoryGirl.create(
          :category,
          taxonomy:progress,
          title:'Complete',
          short_title:'Complete'
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
