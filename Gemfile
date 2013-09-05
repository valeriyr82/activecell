source 'http://rubygems.org'

# Specifying a Ruby Version, see: https://devcenter.heroku.com/articles/ruby-versions
ruby '1.9.3'
gem 'rails', '3.2.8'

# MongoDB support
gem 'mongoid', '3.0.13'

# Authentication solution
gem 'devise'

# Authentication solution for handling Intuit connect and SSO
gem 'omniauth'
# ..for data connection
gem 'omniauth-oauth'
# ..for user SSO
gem 'omniauth-openid'

# DRY API controllers
gem 'inherited_resources'

gem 'recurly'
# Easy crypto for ruby (required for UserVoice soo token generation)
gem 'ezcrypto'

# A simple and straightforward settings solution that uses an ERB enabled YAML file and a singleton design pattern.
gem 'settingslogic'

# file upload
gem 'paperclip'
gem 'mongoid-paperclip', require: 'mongoid_paperclip'
gem 'fog'

# TODO do we really need this gem now?
gem 'google_drive'

# Extract, transform, and load
gem 'activecell-etl', git: 'https://activecell-machine-user:NYVy98BbBb6Lae3DAdfWSLCQ@github.com/activecell/activecell-etl.git', branch: 'master', require: 'etl'
gem 'happymapper', git: 'https://github.com/activecell/happymapper.git'
gem 'intuit-anywhere', '0.1.0', git: 'https://activecell-machine-user:NYVy98BbBb6Lae3DAdfWSLCQ@github.com/activecell/intuit-anywhere.git'

# Manage Procfile-based applications
gem 'foreman'

# background workers
gem 'resque'
gem 'resque-status'
# sending asynchronous email with ActionMailer and Resque
gem 'resque_mailer'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'jquery-rails', '~> 2.1.3' # 1.8.2
  gem 'jquery-fileupload-rails'
  gem 'jquery-ui-rails'
  gem 'bootstrap-colorpicker-rails'
  gem 'rails-backbone', '0.8.0'
  gem 'highcharts-rails'
  gem 'bootstrap-sass'
  gem 'eco'
  gem 'yui-compressor', require: 'yui/compressor'
  gem 'asset_sync'
  gem 'sprockets-commonjs'
  gem 'momentjs-rails'
  gem 'spinjs-rails'

  # Jasmine support
  gem 'jasminerice'
end

group :development, :test do
  gem 'thin'
  gem 'rspec-rails'
  gem 'mailcatcher', require: false
end

group :development, :test, :tddium_ignore do
  gem 'debugger', require: false

  # Pretty print your Ruby objects with style
  gem 'awesome_print'

  # Run specs in parallel
  gem 'parallel_tests'

  # automated jasmine tests in the console
  gem 'guard-jasmine'
  # automatically run your specs
  gem 'guard-rspec'

  # speeds up your Rails testing workflow by preloading your Rails environment
  gem 'spin'
  gem 'guard-spin'
  gem 'rb-fsevent'
end

group :test do
  # Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests.
  gem 'vcr', require: false
  # Library for stubbing and setting expectations on HTTP requests in Ruby. (required by vcr)
  gem 'webmock', require: false

  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-email'
  gem 'factory_girl_rails'
  # Time travels in specs
  gem 'delorean'
  
  # Collection of testing matchers extracted from Shoulda
  gem 'shoulda-matchers'
  # RSpec matchers for Mongoid.
  gem 'mongoid-rspec'
  # Easily handle JSON in RSpec
  gem 'json_spec'

  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

# Heroku environments (staging uses production)
group :production do
  gem 'newrelic_rpm'
  gem 'unicorn'
  gem 'airbrake'
end
