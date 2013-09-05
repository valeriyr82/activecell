if ENV['RAILS_ENV'] == 'production'
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
  end
end