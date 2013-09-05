ActiveCell::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Reloading of classes only when tracked files change
  config.reload_classes_only_on_change = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  # Host for mailer links
  config.action_mailer.default_url_options = { host: 'activecell.local:3000' }

  # Configure VCR to log all HTTP requests
  # See also /config/initializers/vcr_logging.rb
  if ENV['VCR_LOGGING'].present?
    require 'vcr'

    config.middleware.use VCR::Middleware::Rack do |cassette|
      cassette.name    'vcr.log'
      cassette.options record: :all,
                       serialize_with: :syck
    end
  end

  # Update configs to paperclip
  config.paperclip_defaults = {
    storage: :fog,
    fog_credentials: {
      provider: "Local",
      local_root: "#{Rails.root}/public/"
    },
    fog_directory: "",
    fog_host: ""
  }
  
  # If you're using mailcatcher gem.
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :host => 'localhost', :port => 1025 }
end
