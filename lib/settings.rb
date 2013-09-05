class Settings < Settingslogic
  source File.expand_path('../../config/application.yml', __FILE__)
  namespace ENV['RAILS_ENV'] || Rails.env
end
