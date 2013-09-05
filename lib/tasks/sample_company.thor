# TODO refactor this code
class SampleCompany < Thor
  desc 'build', 'Build sample company'
  def build
    boot_rails!
    build_company
  end

  desc 'build_one', 'Destroy the sample company if it exists and build fresh'
  def build_one
    boot_rails!
    remove_sterling_cooper
    Company.skip_callback(:save, :after, :ensure_first_dimensions)
    build_company
    Company.set_callback(:save, :after, :ensure_first_dimensions)
  end

  desc 'demo', 'Create demo companies'
  method_option :count, default: 100, alias: '-c', desc: 'Count of demo companies'
  def demo
    boot_rails! 'demo'

    demo_companies_count = Company.demo_available.count
    puts "Demo company count #{demo_companies_count}"
    count = options[:count] - demo_companies_count
    if count > 0
      puts "Need to create #{count} companies"
      count.times.each { build_company }
    end

    User.demo_taken.demo_inactive.each do |user|
      user.companies.each { |company| company.destroy }
      user.destroy
    end
  end

  desc 'clean', 'Clean all demo companies'
  def clean
    boot_rails! 'demo'

    User.demo_available.each do |user|
      user.companies.each { |company| company.destroy }
      user.destroy
    end

    User.demo_taken.each do |user|
      user.companies.each { |company| company.destroy }
      user.destroy
    end
  end

  private

  def remove_sterling_cooper
    company = Company.where(name: 'Sterling Cooper').first
    if company
      user_affiliations = company.user_affiliations
      company.destroy
      user_affiliations.each { |affiliation| affiliation.user.destroy }
    end

    user = User.where(name: 'Don Draper').first
    if user
      companies = user.companies
      companies.each { |company| company.destroy }
      user.destroy
    end
  end

  def build_company
    user_attributes = {
      name: 'Don Draper',
      email: 'don.draper@sterlingcooper.com'
    }

    company_attributes =  {
      name: 'Sterling Cooper',
      subdomain: 'sterlingcooper',
      country: 'United States',
      zip: '10010',
      url: 'http://sterlingcooper.com',
      industry: 'Services'
    }

    @user       = new_user(user_attributes)
    @company    = create_company(company_attributes)
    @ids        = {}
    @ids[:users] = {}
    @ids[:users][:don] = @user.id
    @ids[:companies] = {}
    @ids[:companies][:sc] = @company.id
    @period_ids = init_periods
    @employee_activities = init_employee_activities

    puts 'Start create base objects'

    load_companies
    load_users
    load_advisor_company
    load_simple_objects
    load_tasks
    load_activity_stream
    load_reports
    load_accounts
    load_customers
    load_employees
    load_channel_segment_mixes

    puts 'Start create history'

    load_conversion_history
    load_financial_history
    load_timesheet_history

    puts 'Start create forecast'

    load_unit_revenue_forecast
    load_unit_cac_forecast
    load_conversion_forecast
    load_churn_forecast
    load_staffing_forecast
    load_expense_forecast

    models = [Scenario, Account, RevenueStream, Product, Channel, Segment,
              Customer, Stage, Employee, EmployeeType, Category, Vendor,
              ConversionSummary, FinancialTransaction, TimesheetTransaction,
              UnitRevForecast, UnitCacForecast, ConversionForecast, ChurnForecast, StaffingForecast, ExpenseForecast]

    puts models.map {|model| "#{model.to_s}: #{model.where(company: @company).size}"}.join(', ')
  end

  def load_companies
    companies = [
      {
        name: 'Sterling Cooper Draper Pryce',
        subdomain: 'scdp',
        country: 'United States',
        zip: '10010',
        url: 'http://sterlingcooperdraperpryce.com',
        industry: 'Services'
      }
    ]

    companies.each do |attributes|
      company = Company.where(name: attributes[:name]).first
      company.destroy if company
      create_company attributes
    end
  end

  def load_users
    unless Rails.env.demo?
      
      # TODO clean this. I know it's not DRY, but for whatever reason the IDs
      #   weren't registering when executed the expected way.

      user = User.where(name: 'Roger Sterling').destroy_all
      user = User.where(name: 'Bert Cooper').destroy_all
      user = User.where(name: 'Pete Campbell').destroy_all

      new_user =  User.create!({name: 'Roger Sterling', email: 'roger.sterling@sterlingcooper.com', password: '111111', password_confirmation: '111111'})
      @ids[:users][:roger] = new_user.id
      @company.invite_user(new_user)
      
      new_user =  User.create!({name: 'Bert Cooper', email: 'bert.cooper@sterlingcooper.com', password: '111111', password_confirmation: '111111'})
      @ids[:users][:bert] = new_user.id
      @company.invite_user(new_user)
      
      new_user =  User.create!({name: 'Pete Campbell', email: 'pete.campbell@sterlingcooper.com', password: '111111', password_confirmation: '111111'})
      @ids[:users][:pete] = new_user.id
      @company.invite_user(new_user)

    end
  end

  def load_advisor_company
    company_attributes = {
      name: 'Connected Bookkeepers',
      subdomain: 'connected-bookkeepers',
      url: 'http://connectedbookkeepers.com'
    }

    company = Company.where(name: company_attributes[:name]).first
    company.destroy if company
    company = create_company company_attributes
    company = company.upgrade_to_advisor!

    user_attributes = {
      name: 'Joan Harris',
      email: 'joan.harris@connected-bookkeepers.com'
    }

    user = User.where(name: user_attributes[:name]).first
    user.destroy if user

    new_user = new_user(user_attributes)
    new_user.save!
    @ids[:users][:joan] = new_user.id
    company.invite_user(new_user)

    advised_company = Company.where(name: 'Sterling Cooper').first
    advised_company.invite_advisor(company)
  end

  # Load objects without parent keys
  def load_simple_objects
    simple_objects = {}
    simple_objects[:scenarios] = [
      {id: :base,       name: 'Base'},
      {id: :optimistic, name: 'Optimistic'}
    ]
    simple_objects[:products] = [
      {id: :consulting,     name: 'Consulting'},
      {id: :tv_ads,         name: 'Television ads'},
      {id: :radio_ads,      name: 'Radio ads'},
      {id: :billboard_ads,  name: 'Billboard ads'},
      {id: :mag_ads,        name: 'Magazine ads'},
      {id: :conferences,    name: 'Conferences'},
      {id: :affiliate_rev,  name: 'Affiliate revenue'}
    ]
    simple_objects[:segments] = [
      {id: :platinum, name: 'Platinum'},
      {id: :gold,     name: 'Gold'},
      {id: :silver,   name: 'Silver'}
    ]
    simple_objects[:stages] = [
      {id: :customer, name: 'Customer', position: 1},
      {id: :lead,     name: 'Lead',     position: 2},
      {id: :prospect, name: 'Prospect', position: 3, lag_periods: 1}
    ]
    simple_objects[:employee_types] = [
      {id: :partner,    name: 'Partner'},
      {id: :creative,   name: 'Creative'},
      {id: :acct_exec,  name: 'Account Executive'},
      {id: :assistant,  name: 'Assistant'}
    ]
    simple_objects[:vendors] = [
      {id: :big_media,  name: 'Big Media Co.'},
      {id: :mad_props,  name: 'Madison Avenue Properties'},
      {id: :winston,    name: 'Winston\'s Cigars'},
      {id: :staples,    name: 'Staples'},
      {id: :staples,    name: 'Derek the contractor', is_contractor: true}
    ]
    simple_objects.each do |object_name, collection|
      collection.each do |attributes|
        create_object! object_name, attributes[:id], without(attributes, [:id])
      end
    end
  end

  def load_tasks
    tasks = [
      {id: :a, text: 'Hire new creative'                    , done: false, user_id: :don},
      {id: :b, text: 'Review books for sketchy bonus checks', done: false, user_id: :bert},
      {id: :c, text: 'Order more whiskey'                   , done: false, user_id: :pete},
      {id: :d, text: 'Sketch out plot concepts for season 3', done: true , user_id: :roger}
    ]
    tasks.each do |attributes|
      user_id = @ids[:users][attributes[:user_id]]
      create_object! :tasks, attributes[:id], without(attributes, [:id]).merge(user_id: user_id)
    end
  end
  
  def load_activity_stream
    activities = [
      {id: :e, content: "Closed your books for the month. There were a few invoices I couldn't reconcile but they are small so we will get to them next month.", sender_id: :joan},
      {id: :f, content: "Another great month, team. Nice work. Let's just get that churn rate down.", sender_id: :bert},
      {id: :g, content: 'Team, looks like we missed our sales targets for last quarter. Not pleased.', sender_id: :don}
    ]
    activities.each do |attributes|
      sender_id = @ids[:users][attributes[:sender_id]]
      create_object! :activities, attributes[:id], without(attributes, [:id]).merge(sender_id: sender_id)
    end
  end
  
  def load_reports
    dashboard = @company.reports.create!({report_type: 1, name: 'dashboard'})
    [
      {"analysisCategory"=>"customers", "prefix"=>"index", "analysisId"=>"volume"},
      {"analysisCategory"=>"customers", "prefix"=>"index", "analysisId"=>"nps"},
      {"analysisCategory"=>"channels", "prefix"=>"index", "analysisId"=>"conversion"},
      {"analysisCategory"=>"products", "prefix"=>"index", "analysisId"=>"mrr"}
    ].each { |analysis| dashboard.analyses.create! analysis }

    investor = @company.reports.create!({report_type: 0, name: 'investor'})
    [
      {"analysisCategory"=>"channels", "prefix"=>"index", "analysisId"=>"reach"},
      {"analysisCategory"=>"company", "prefix"=>"index", "analysisId"=>"cash_flow"},
      {"analysisCategory"=>"company", "prefix"=>"index", "analysisId"=>"burn_runway"},
      {"analysisCategory"=>"customers", "prefix"=>"index", "analysisId"=>"nps"},
      {"analysisCategory"=>"segments", "prefix"=>"index", "analysisId"=>"customer_equity"},
      {"analysisCategory"=>"employee_types", "prefix"=>"index", "analysisId"=>"utilization"}
    ].each { |analysis| investor.analyses.create! analysis }
    
    board = @company.reports.create!({report_type: 0, name: 'board'})
    [
      {"analysisCategory"=>"customers", "prefix"=>"index", "analysisId"=>"volume"},
      {"analysisCategory"=>"customers", "prefix"=>"index", "analysisId"=>"nps"},
      {"analysisCategory"=>"segments", "prefix"=>"index", "analysisId"=>"customer_equity"}
    ].each { |analysis| board.analyses.create! analysis }
    
  end

  def load_accounts
    @ids[:accounts] = {}
    accounts = [
      # Assets
      {
        id: :primary_checking, name: 'Primary Checking Account', type: 'Asset',
        sub_type: 'Checking', activecell_category: 'cash',
        current_balance: 1_000_000_00,
        balance_as_of: '2012-01-01'
      },
      {
        id: :primary_savings, name: 'Primary Savings Account', type: 'Asset',
        sub_type: 'Savings', activecell_category: 'cash',
        current_balance: 100_000_00,
        balance_as_of: '2012-01-01'
      },
      {
        id: :accounts_receivable, name: 'Accounts Receivable', type: 'Asset',
        sub_type: 'AccountsReceivable', activecell_category: 'non-cash',
        current_balance: 10_000_00,
        balance_as_of: '2012-01-01'
      },
      # Liabilities
      {
        id: :primary_credit, name: 'Primary Credit Card', type: 'Liability',
        sub_type: 'CreditCard', activecell_category: 'short-term',
        current_balance: 20_000_00,
        balance_as_of: '2012-01-01'
      },
      {
        id: :bank_loan, name: 'Bank Loan', type: 'Liability',
        sub_type: 'NotesPayable', activecell_category: 'long-term',
        current_balance: 200_000_00,
        balance_as_of: '2012-01-01'
      },
      {
        id: :accounts_payable, name: 'Accounts Payable', type: 'Liability',
        sub_type: 'AccountsPayable', activecell_category: 'short-term',
        current_balance: 2_000_00,
        balance_as_of: '2012-01-01'
      },
      # Equity
      {
        id: :common_stock, name: "Common Stock", type: 'Equity',
        sub_type: 'CommonStock',
        current_balance: 800_000_00,
        balance_as_of: '2012-01-01'
      },
      {
        id: :preferred_stock, name: 'Preferred Stock', type: 'Equity',
        sub_type: 'PreferredStock',
        current_balance: 80_000_00,
        balance_as_of: '2012-01-01'
      },
      {
        id: :retained_earnings, name: 'Retained Earnings', type: 'Equity',
        sub_type: 'RetainedEarnings',
        current_balance: 8_000_00,
        balance_as_of: '2012-01-01'
      },
      # Revenue
      {
        id: :services, name: 'Professional services', type: 'Revenue',
        sub_type: 'ServiceFeeIncome'
      },
      {
        id: :media, name: 'Media purchases', type: 'Revenue',
        sub_type: 'SalesOfProductIncome'
      },
      {
        id: :event_rev, name: 'Event revenue', type: 'Revenue',
        sub_type: 'ServiceFeeIncome'
      },
      {
        id: :discounts, name: 'Discounts & Refunds', type: 'Revenue',
        sub_type: 'DiscountsRefundsGiven'
      },
      # COGS:
      {
        id: :media_buys, name: 'Media buys', type: 'Cost of Goods Sold',
        subtype: 'SuppliesMaterialsCogs'
      },
      # Expense: Payroll
      {
        id: :payroll, name: 'Payroll', type: 'Expense',
        subtype: 'PayrollExpenses', activecell_category: 'payroll'
      },
      {
        id: :wages_salaries, name: 'Wages & Salaries', type: 'Expense',
        subtype: 'PayrollExpenses', activecell_category: 'payroll',
        parent_account_id: :payroll
      },
      {
        id: :benefits, name: 'Benefits', type: 'Expense',
        subtype: 'PayrollExpenses', activecell_category: 'payroll',
        parent_account_id: :payroll
      },
      {
        id: :payroll_taxes, name: 'Payroll Taxes', type: 'Expense',
        subtype: 'PayrollExpenses', activecell_category: 'payroll',
        parent_account_id: :payroll
      },
      {
        id: :benefits_admin, name: 'Benefits Admin', type: 'Expense',
        subtype: 'PayrollExpenses', activecell_category: 'payroll',
        parent_account_id: :payroll
      },
      # Expense: CAC
      {
        id: :content, name: 'Content marketing', type: 'Expense',
        subtype: 'AdvertisingPromotional', activecell_category: 'sales & marketing'
      },
      {
        id: :sales, name: 'Direct sales', type: 'Expense',
        subtype: 'AdvertisingPromotional', activecell_category: 'sales & marketing'
      },
      {
        id: :events, name: 'Events', type: 'Expense',
        subtype: 'AdvertisingPromotional', activecell_category: 'sales & marketing'
      },
      {
        id: :referral, name: 'Referral', type: 'Expense',
        subtype: 'AdvertisingPromotional', activecell_category: 'sales & marketing'
      },
      {
        id: :sem, name: 'Search engine marketing', type: 'Expense',
        subtype: 'AdvertisingPromotional', activecell_category: 'sales & marketing'
      },      
      # Expense: General
      {
        id: :meals, name: 'Meals', type: 'Expense', 
        subtype: 'TravelMeals', activecell_category: 'other'
      },
      {
        id: :rent, name: 'Rent', type: 'Expense', 
        subtype: 'RentOrLeaseOfBuildings', activecell_category: 'other'
      },
      {
        id: :office_supplies, name: 'Office Supplies', type: 'Expense', 
        subtype: 'OfficeGeneralAdministrativeExpenses', activecell_category: 'other'
      },
      {
        id: :legal, name: 'Legal Fees', type: 'Expense', 
        subtype: 'LegalProfessionalFees', activecell_category: 'other'
      },
      # non-posting
      {
        id: :purchase_orders, name: 'Purchase Orders', type: 'Non-Posting'
      }
    ]
    accounts.each do |attributes|
      parent_id = @ids[:accounts][attributes[:parent_account_id]]
      
      # create a revenue stream for every revenue account and link them
      if attributes[:type] == 'Revenue'
        revenue_stream_id = create_object!(:revenue_streams, attributes[:id],
          attributes.reject{ |k,v| [:id, :type, :subtype].include? k}).id
        create_object! :accounts, attributes[:id], without(attributes, [:id]).
          merge(revenue_stream_id: revenue_stream_id, parent_account_id: parent_id)

      # create a channel for every "s&m" account
      elsif attributes[:activecell_category] == 'sales & marketing'
        channel_id = create_object!(:channels, attributes[:id],
          attributes.reject{ |k,v| [:id, :type, :subtype, :activecell_category].include? k}).id
        create_object! :accounts, attributes[:id], without(attributes, [:id]).
          merge(channel_id: channel_id, parent_account_id: parent_id)        

      # create a category for every "other expense" account
      elsif attributes[:activecell_category] == 'other'
        category_id = create_object!(:categories, attributes[:id],
          attributes.reject{ |k,v| [:id, :type, :subtype, :activecell_category].include? k}).id
        create_object! :accounts, attributes[:id], without(attributes, [:id]).
          merge(category_id: category_id, parent_account_id: parent_id)        
      
      # create just the account itself on its own if nothing matches
      else
        create_object! :accounts, attributes[:id], without(attributes, [:id]).merge(parent_account_id: parent_id)
      end
    end
    
  end

  def load_customers
    customers = [
      {id: :lucky_strike, name: 'Lucky Strike',       segment_id: :platinum,  channel_id: :content},
      {id: :london_fog,   name: 'London Fog',         segment_id: :gold,      channel_id: :sales},
      {id: :unilever,     name: 'Unilever',           segment_id: :silver,    channel_id: :events},
      {id: :heineken,     name: 'Heineken',           segment_id: :platinum,  channel_id: :referral},
      {id: :maidenform,   name: 'Maidenform',         segment_id: :gold,      channel_id: :sem},
      {id: :gilette,      name: 'Gilette',            segment_id: :silver,    channel_id: :content},
      {id: :american_air, name: 'American Airlines',  segment_id: :platinum,  channel_id: :sales},
      {id: :clearasil,    name: 'Clearasil',          segment_id: :gold,      channel_id: :events},
      {id: :vicks,        name: 'Vicks Chemical',     segment_id: :silver,    channel_id: :referral}
    ]
    customers.each do |attributes|
      segment_id = @ids[:segments][attributes[:segment_id]]
      channel_id = @ids[:channels][attributes[:channel_id]]
      create_object! :customers, attributes[:id], without(attributes, [:id]).merge(segment_id: segment_id, channel_id: channel_id)
    end
  end

  def load_employees
    employees = [
      {id: :roger,  name: 'Roger Sterling', employee_type_id: :partner},
      {id: :bert,   name: 'Bert Cooper',    employee_type_id: :partner},
      {id: :don,    name: 'Don Draper',     employee_type_id: :creative},
      {id: :harry,  name: 'Harry Crane',    employee_type_id: :creative},
      {id: :paul,   name: 'Paul Kinsey',    employee_type_id: :creative},
      {id: :sal,    name: 'Sal Romano',     employee_type_id: :creative},
      {id: :pete,   name: 'Pete Campbell',  employee_type_id: :creative},
      {id: :ken,    name: 'Ken Cosgrove',   employee_type_id: :acct_exec},
      {id: :duck,   name: 'Duck Philips',   employee_type_id: :acct_exec},
      {id: :peggy,  name: 'Peggy Olson',    employee_type_id: :assistant}
    ]
    employees.each do |attributes|
      employee_type_id = @ids[:employee_types][attributes[:employee_type_id]]
      create_object! :employees, attributes[:id], without(attributes, [:id]).merge(employee_type_id: employee_type_id)
    end
  end

  def load_channel_segment_mixes
    channel_segment_mix = {
      content:  {platinum: 100},
      sales:    {platinum: 25, gold: 25, silver: 50},
      events:   {gold: 100},
      referral: {platinum: 20, gold: 40, silver: 40},
      sem:      {platinum: 30, gold: 5, silver: 65}
    }

    channel_segment_mix.each do | channel_id, hash |
      channel = Channel.find(@ids[:channels][channel_id])
      array = []
      hash.each do | segment_id, distribution |
        new_hash = {
          segment_id: @ids[:segments][segment_id],
          distribution: (distribution.to_f / 100.0)
        }
        array << new_hash
      end

      channel.channel_segment_mix = array
      channel.save!
    end
  end

  def load_conversion_history
    conversion_history = [
      # content
      {channel_id: :content, stage_id: :prospect, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :content, stage_id: :lead, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :content, stage_id: :customer, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      # sales
      {channel_id: :sales, stage_id: :prospect, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :sales, stage_id: :lead, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :sales, stage_id: :customer, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      # events
      {channel_id: :events, stage_id: :prospect, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :events, stage_id: :lead, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :events, stage_id: :customer, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      # sem
      {channel_id: :sem, stage_id: :prospect, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :sem, stage_id: :lead, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :sem, stage_id: :customer, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      # referral
      {channel_id: :referral, stage_id: :prospect, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :referral, stage_id: :lead, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :referral, stage_id: :customer, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]}
    ]
    conversion_history.each do |attributes|
      attributes[:channel_id]      = @ids[:channels][attributes[:channel_id]]
      attributes[:stage_id]        = @ids[:stages][attributes[:stage_id]]
      attributes[:values].each_with_index do | value, i |
        attributes[:period_id]       = @period_ids[i-36]
        attributes[:customer_volume] = value
        create_object! :conversion_summary, nil, without(attributes, [:values])
      end
    end
  end

  def load_financial_history
    financial_history = [
      {account_id: :wages_salaries, employee_id: :don, values: [
        10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,
        10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,
        10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000,  10000
      ]}
    ]
    financial_history.each do |attributes|
      attributes[:account_id]   = @ids[:accounts][attributes[:account_id]]
      attributes[:product_id]   = @ids[:products][attributes[:product_id]]
      attributes[:customer_id]  = @ids[:customers][attributes[:customer_id]]
      attributes[:employee_id]  = @ids[:employees][attributes[:employee_id]]
      attributes[:vendor_id]    = @ids[:vendors][attributes[:vendor_id]]

      attributes[:values].each_with_index do | value, i |
        attributes[:period_id]       = @period_ids[i-36]
        attributes[:amount_cents] = value * 100
        create_object! :financial_transactions, nil, without(attributes, [:values])
      end
    end
  end

  def load_timesheet_history
    timesheet_history = [
      {employee_activity_id: :sales, employee_id: :don, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]}
    ]
    timesheet_history.each do |attributes|
      attributes[:employee_activity_id] = @employee_activities[attributes[:employee_activity_id]]
      attributes[:product_id]     = @ids[:products][attributes[:product_id]]
      attributes[:customer_id]    = @ids[:customers][attributes[:customer_id]]
      attributes[:employee_id]    = @ids[:employees][attributes[:employee_id]]

      attributes[:values].each_with_index do | value, i |
        attributes[:period_id]       = @period_ids[i-36]
        attributes[:amount_minutes] = value
        create_object! :timesheet_transactions, nil, without(attributes, [:values])
      end
    end
  end

  def load_unit_revenue_forecast
    unit_revenue_forecast = [
      {segment_id: :platinum, revenue_stream_id: :services,   unit_rev_forecast: 10_000},
      {segment_id: :platinum, revenue_stream_id: :media,      unit_rev_forecast: 10_000},
      {segment_id: :platinum, revenue_stream_id: :event_rev,  unit_rev_forecast: 10_000},
      {segment_id: :gold,     revenue_stream_id: :services,   unit_rev_forecast: 10_000},
      {segment_id: :gold,     revenue_stream_id: :media,      unit_rev_forecast: 10_000},
      {segment_id: :gold,     revenue_stream_id: :event_rev,  unit_rev_forecast: 10_000},
      {segment_id: :silver,   revenue_stream_id: :services,   unit_rev_forecast: 10_000},
      {segment_id: :silver,   revenue_stream_id: :media,      unit_rev_forecast: 10_000},
      {segment_id: :silver,   revenue_stream_id: :event_rev,  unit_rev_forecast: 10_000},
    ]
    unit_revenue_forecast.each do |attributes|
      attributes[:scenario_id]       = @ids[:scenarios][:base]
      attributes[:segment_id]        = @ids[:segments][attributes[:segment_id]]
      attributes[:revenue_stream_id] = @ids[:revenue_streams][attributes[:revenue_stream_id]]
      attributes[:unit_rev_forecast] = attributes[:unit_rev_forecast] * 100

      create_object! :unit_rev_forecast, nil, attributes
    end
  end

  def load_unit_cac_forecast
    unit_cac_forecast = [
      {channel_id: :content, account_id: :sales_commissions,   unit_cac_forecast: 50}
    ]
    unit_cac_forecast.each do |attributes|
      attributes[:scenario_id] = @ids[:scenarios][:base]
      attributes[:channel_id]  = @ids[:channels][attributes[:channel_id]]
      attributes[:account_id] = @ids[:accounts][attributes[:account_id]]
      attributes[:unit_cac_forecast] = attributes[:unit_cac_forecast] * 100

      create_object! :unit_cac_forecast, nil, attributes
    end
  end

  def load_conversion_forecast

    conversion_forecast = [
      # content
      {channel_id: :content, stage_id: :prospect, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0,
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :content, stage_id: :lead, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0,
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {channel_id: :content, stage_id: :customer, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0,
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]}
    ]
    conversion_forecast.each do |attributes|
      attributes[:scenario_id]         = @ids[:scenarios][:base]
      attributes[:channel_id]          = @ids[:channels][attributes[:channel_id]]
      attributes[:stage_id]            = @ids[:stages][attributes[:stage_id]]
      attributes[:values].each_with_index do | value, i |
        attributes[:period_id]       = @period_ids[i-36]
        attributes[:conversion_forecast] = value
        create_object! :conversion_forecast, nil, without(attributes, [:values])
      end
    end
  end

  def load_churn_forecast
    churn_forecast = [
      {segment_id: :platinum, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0,
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {segment_id: :gold, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0,
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]},
      {segment_id: :silver, values: [
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0,
        4,    4,    4,    17,   17,   7,    7,    4,    12,   18,   4,    1,
        15,   3,    18,   18,   16,   8,    14,   20,   4,    17,   11,   18,
        17,   20,   13,   12,   1,    12,   16,   0,    3,    13,   2,    0
      ]}
    ]
    churn_forecast.each do |attributes|
      attributes[:scenario_id]    = @ids[:scenarios][:base]
      attributes[:segment_id]     = @ids[:segments][attributes[:segment_id]]
      attributes[:values].each_with_index do | value, i |
        attributes[:period_id]       = @period_ids[i-36]
        attributes[:churn_forecast] = value
        create_object! :conversion_forecast, nil, without(attributes, [:values])
      end
    end
  end

  def load_staffing_forecast
    staffing_forecasts = [
      {
        employee_type_id: :creative,
        occurence: 'monthly', fixed_delta: 1
      },
      {
        employee_type_id: :partner,
        occurence: 'annually', occurrence_month: 3, fixed_delta: 1
      },
      {
        employee_type_id: :assistant,
        occurence: 'fixed', occurrence_period_id: 10, fixed_delta: 1
      },
      {
        employee_type_id: :acct_exec,
        occurence: 'revenue threshold', revenue_threshold: 500_000_00
      },
    ]
    staffing_forecasts.each do |attributes|
      attributes[:scenario_id]          = @ids[:scenarios][:base]
      attributes[:employee_type_id]     = @ids[:employee_types][attributes[:employee_type_id]]
      attributes[:occurrence_period_id] = @period_ids[attributes[:occurrence_period_id]] if attributes[:occurrence_period_id]

      create_object! :staffing_forecasts, nil, attributes
    end
  end

  def load_expense_forecast
    expense_forecasts = [
      {
        name: 'office supplies', category_id: :office_supplies,
        occurence: 'monthly', fixed_cost: 250_00
      },
      {
        name: 'holiday trip', category_id: :travel,
        occurence: 'annually', occurrence_month: 12, fixed_cost: 10_000_00
      },
      {
        name: 'new computer', category_id: :it_hardware,
        occurence: 'fixed', occurrence_period_id: 10, fixed_cost: 2_000_00
      },
      {
        name: 'client meals', category_id: :meals,
        occurence: 'revenue percent', percent_revenue: 0.00001
      },
      {
        name: 'rent', category_id: :rent,
        occurence: 'employee count', fixed_cost: 500_00
      }
    ]
    expense_forecasts.each do |attributes|
      attributes[:scenario_id]          = @ids[:scenarios][:base]
      attributes[:category_id]          = @ids[:categories][attributes[:category_id]]
      attributes[:occurrence_period_id] = @period_ids[attributes[:occurrence_period_id]] if attributes[:occurrence_period_id]

      create_object! :expense_forecasts, nil, attributes
    end
  end

  # Helpers

  def without(hash, skip_attrs = [])
    skip_attrs.each do |skip_attr|
      hash.delete(skip_attr)
    end
    hash
  end

  def new_user(attributes)
    user = User.find_by_email attributes[:email]
    user.destroy if user
    User.create! attributes.merge(password: '111111', password_confirmation: '111111')
  end

  def create_company(attributes)
    company = Company.create!(attributes)
    company.invite_user(@user)
    company
  end

  def create_object!(collection, id, attributes)
    begin
      object = @company.send(collection).create! attributes
      @ids[collection] ||= {}
      @ids[collection][id] = object.id if id
      object
    rescue Exception => e
      puts collection, attributes
      puts e.to_s
    end
  end

  def init_periods
    period_ids = {}
    now = Time.now
    Period.all.each do |period|
      period_date = period.first_day
      diff = (period_date.year*12 + period_date.month) - (now.year*12 + now.month)
      period_ids[diff] = period.id
    end
    period_ids
  end

  def init_employee_activities
    employee_activities = {}
    EmployeeActivity::NAMED_ACTIVITIES.each do |key,employee_activity|
      employee_activities[key] = EmployeeActivity.find_or_create_by(name: employee_activity).id
    end
    employee_activities
  end

  def boot_rails!(env = 'development')
    ENV["RAILS_ENV"] ||= env
    require './config/environment'
  end
end
