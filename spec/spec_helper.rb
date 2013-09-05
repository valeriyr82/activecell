if ENV['DRB'].nil? and ENV['TEST_ENV_NUMBER'].nil? and not ENV['COVERAGE'].nil?
  require 'simplecov'
  require 'simplecov-rcov'
end

require 'rubygems'
require 'paperclip/matchers'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/email/rspec'

require 'vcr'
VCR.configure do |c|
  c.ignore_localhost = true

  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = {
      record: :once,
      match_requests_on: [:method, :uri, :body],
      serialize_with: :syck
  }
  c.cassette_library_dir = File.expand_path('spec/vcr_cassettes', Rails.root)
  c.hook_into :webmock

  if ENV['DEBUG_VCR'].present?
    c.debug_logger = File.open(Rails.root.join('log/vcr_debug.log'), 'w')
  end
end

OmniAuth.config.test_mode = true

# Init Capybara
require 'capybara/rspec'

# Here be dragons... again
if ENV['FORCE_SELENIUM']
  # Use selenium driver on out CI since it seems to be more stable (I should say: don't try this is at home ;)
  # Note: in order to simulate slow ajax calls and weird timeouts errors the following code snipped could be user: https://gist.github.com/150b2cd425a7ebcfec1f
  Capybara.javascript_driver = :selenium
else
  # otherwise on local machines use webkit
  require 'capybara/webkit'

  # Silent js console
  # @see http://stackoverflow.com/questions/11672337/avoid-capybaras-webkit-console-log-output
  Capybara.register_driver :webkit_silent do |app|
    Capybara::Driver::Webkit.new(app, :stdout => nil)
  end

  Capybara.javascript_driver = :webkit_silent
end

Capybara.default_wait_time = 5
Capybara.ignore_hidden_elements = true
Capybara.current_session.driver.reset!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Moped::Protocol::Insert.class_eval do
  def log_inspect_with_instrument
    ActiveSupport::Notifications.instrument('mongodb.insert', collection: collection, documents: documents)
    log_inspect_without_instrument
  end

  alias_method_chain :log_inspect, :instrument
end

RSpec.configure do |config|
  config.order = 'random'

  # Use symbols as metadata
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Mock Framework
  config.mock_with :rspec

  # Add VCR macros
  config.extend VCR::RSpec::Macros

  # Support FactoryGirl short syntax without FactoryGirl prefix
  config.include FactoryGirl::Syntax::Methods

  # Include matchers for Mongoid
  config.include Mongoid::Matchers, type: :model

  # Include matchers for Paperclip
  config.include Paperclip::Shoulda::Matchers

  # Enable macros for time travelling
  config.include Delorean

  # Extensions for ETL specs
  config.include ETLExampleGroup, :type => :etl, :example_group => {
      :file_path => config.escaped_path(%w[spec lib/etl])
  }

  # Disable all observers in non-integration specs
  config.around(:each) do |example|
    disable = example.metadata[:type] != :request

    Mongoid.observers.disable(:all) if disable
    example.run
    Mongoid.observers.enable(:all) if disable
  end

  # Include custom macros
  config.with_options(type: :request) do |integration_config|
    integration_config.include Macros::Integration
    integration_config.include Macros::Integration::Recurly
    integration_config.include Macros::UserLogin
  end

  # Switch off Fog mocking in the integration specs
  config.around(:each, type: :request) do |example|
    Fog.unmock! if Fog.mocking?
    example.run
    Fog.mock! if not Fog.mocking?
  end

  config.with_options(type: :controller) do |controller_config|
    # Include Devise macros for controller specs
    controller_config.include Devise::TestHelpers
    controller_config.include Macros::Controller
  end

  # Clean up all collections before each spec runs.
  config.before do
    Mongoid.purge!
  end

  config.after do
    on_tddium = ENV['TDDIUM'].present?
    if example.metadata[:type] == :request and not on_tddium
      Helpers.capture_output_for(page, example)
    end
  end

  # If true, the base class of anonymous controllers will be inferred automatically.
  config.infer_base_class_for_anonymous_controllers = false

  # Disable view rendering
  config.render_views = false
end
