module Macros

  module Controller
    # Helper for mocking Devise's #current_user in controller specs
    # see: https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
    def login_as(user)
      request.env['warden'] = warder_mock_for(user)
    end

    private

    def warder_mock_for(user)
      options = {
          user: user,
          authenticate: user,
          authenticate!: user
      }
      mock(Warden, options)
    end
  end

end
