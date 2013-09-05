module OmniAuth
  module Strategies

    # OpenID strategy for Intuit
    class IntuitSso < OmniAuth::Strategies::OpenID
      option :name, "intuit_sso"
      option :identifier, "https://appcenter.intuit.com/identity-me"
    end
  end
end
