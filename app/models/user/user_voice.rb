# Encapsulates logic for UserVoice
# @see https://profitably.uservoice.com/admin/docs
class User
  module UserVoice
    extend ActiveSupport::Concern

    included do
      # If this variable is set, user attempts to login via UserVoice
      attr_accessor :uv_login
    end

    def uv_sso_token(options = {})
      options.reverse_merge!(uv_default_options)

      encrypted = uv_key.encrypt(options.to_json)
      Base64.encode64(encrypted).gsub(/\n/, '')
    end

    private

    def uv_key
      @uv_key ||= begin
        uv_config = Settings.user_voice
        EzCrypto::Key.with_password(uv_config.subdomain, uv_config.sso_key)
      end
    end

    # Returns hash with default options for UserVoice sso
    # @see https://profitably.uservoice.com/admin/docs#/sso
    def uv_default_options
      {
          guid: id,
          email: email,
          display_name: name,
          expires: (Time.zone.now.utc + 5 * 60).to_s
      }
    end

  end
end
