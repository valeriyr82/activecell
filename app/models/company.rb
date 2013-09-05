class Company
  RESERVED_SUBDOMAINS = %w(www jenkins admin launchpad demo mail feedback support)

  include Api::NameDocument
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  include Company::Demo
  include Company::QuickBooks
  include Company::Invitable
  include Company::Affiliations
  include Company::AdvisorUpgrade
  include Company::Branding
  include Company::Billing
  include Company::BackgroundJobs

  field :subdomain, type: String
  field :url, type: String

  field :address_1, type: String
  field :address_2, type: String
  field :postal_code, type: String

  has_many :reports
  # Canonical
  belongs_to :industry
  belongs_to :country

  # Activities
  has_many :activities

  # Company
  has_many :accounts
  has_many :scenarios
  # Customer
  has_many :customers
  has_many :channels
  has_many :segments
  has_many :stages
  # Employee
  has_many :employees
  has_many :employee_types
  # Product
  has_many :products
  has_many :revenue_streams
  # Vendors
  has_many :vendors
  has_many :categories
  # Tasks
  has_many :tasks

  # Historical
  has_many :conversion_summary, class_name: 'ConversionSummary'
  has_many :documents
  has_many :financial_transactions
  has_many :timesheet_transactions

  # Law of Demeter delegators
  delegate :summary, to: :financial_transactions, prefix: true
  delegate :by_params, to: :financial_transactions, prefix: true
  delegate :summary, to: :timesheet_transactions, prefix: true
  delegate :by_params, to: :timesheet_transactions, prefix: true

  # Forecasts
  has_many :churn_forecast, class_name: 'ChurnForecast'
  has_many :conversion_forecast, class_name: 'ConversionForecast'
  has_many :unit_cac_forecast, class_name: 'UnitCacForecast'
  has_many :unit_rev_forecast, class_name: 'UnitRevForecast'
  has_many :expense_forecasts
  has_many :staffing_forecasts

  validates :name, uniqueness: true, unless: :is_demo?
  validates :subdomain, uniqueness: true,
            length: { minimum: 1, maximum: 63 },
            format: { with: /^[a-zA-Z0-9][a-zA-Z0-9.-]+[a-zA-Z0-9]$/, allow_blank: true },
            exclusion: { in: RESERVED_SUBDOMAINS },
            unless: :is_demo?

  index({ name: 1 })
  index({ subdomain: 1 }, { unique: true })

  after_save :ensure_first_dimensions

  # filter methods (in place of scopes)
  class << self
    def find_by_subdomain(subdomain)
      find_by(subdomain: subdomain)
    end
  end

  def as_json(options = {})
    only = [:id, :_type, :name, :subdomain,
            :address_1, :address_2, :postal_code, :url,
            :industry_id, :country_id, :advisor]
    options.reverse_merge!(only: only)
    options.reverse_merge!(except: [])

    super(options).tap do |json|
      # Intuit QuickBooks stuff
      json[:is_connected_to_intuit] = connected_to_intuit? unless options[:except].include?(:is_connected_to_intuit)
      json[:is_intuit_token_expired] = intuit_token_expired? unless options[:except].include?(:is_intuit_token_expired)
      json[:is_advised] = advised?

      if advised?
        json[:is_branding_overridden] = branding_overridden?
      end

      unless billing_overridden?
        json[:is_in_trial] = subscriber.in_trial?
        json[:is_trial_expired] = subscriber.trial_expired?
        json[:trial_days_left] = subscriber.trial_days_left
      end

      json[:logo_url] = branding.logo_url
      json[:logo_file_name] = branding.logo_file_name
    end
  end

  def current_scenario(scenario_id)
    scenario = scenarios.where(id: scenario_id).first if scenario_id
    scenario || scenarios.first
  end

  # Generates suggested subdomain from the name
  # * downcase all characters
  # * remove illegal characters
  # * substitute white characters
  def suggested_subdomain
    name
    .downcase
    .gsub(/[^a-zA-Z\d\-\s]/, '') # illegal chars
    .gsub(/(\s)+/, '-') # white chars
  end

  private

  # Confirm that at least 1 record exists for each model that includes
  # Api:ValidateLast. In essence, this method ensures that at least
  # one record exists per company, and ValidateLast ensures that at
  # least one remains
  #
  # Returns nothing
  def ensure_first_dimensions
    [
      [scenarios, Scenario],
      [revenue_streams, RevenueStream],
      [segments, Segment],
      [channels, Channel],
      [stages, Stage],
      [employee_types, EmployeeType],
      [categories, Category]
    ].each do |data|
      collection, class_name = data
      collection.create!(name: class_name::DEFAULT_NAME) if collection.blank?
    end
  end
end
