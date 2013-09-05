require 'omniauth/strategies/intuit'
require 'omniauth/strategies/intuit_sso'

# Rails application example
OmniAuth.config.logger = Rails.logger

key = Settings.intuit.consumer_key
secret = Settings.intuit.consumer_secret

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :intuit, key, secret
  provider :intuit_sso
end

Intuit::Api.oauth_consumer_key = key
Intuit::Api.oauth_consumer_secret = secret
