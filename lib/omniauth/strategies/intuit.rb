module OmniAuth
  module Strategies

    # OAuth strategy for Intuit
    # @see: https://github.com/intridea/omniauth-oauth#creating-an-oauth-strategy
    class Intuit < OmniAuth::Strategies::OAuth
      option :name, 'intuit'

      option :client_options, {
          site:               'https://oauth.intuit.com',
          request_token_path: '/oauth/v1/get_request_token',
          access_token_path:  '/oauth/v1/get_access_token',
          authorize_url:      'https://workplace.intuit.com/Connect/Begin'
      }
    end

  end
end
