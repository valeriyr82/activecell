# Encapsulates logic for integration with Intuit
module User::IntuitSso
  extend ActiveSupport::Concern

  included do
    field :intuit_openid_identifier, type: String
    index({ intuit_openid_identifier: 1 })
  end

  module ClassMethods

    # Creates a new user instance from Intuit auth hash
    def new_from_auth_hash(auth_hash)
      User.new do |user|
        user.intuit_openid_identifier = auth_hash[:uid]

        info = auth_hash[:info]
        user.email = info[:email]
        user.name = info[:name]

        # Generate password
        # TODO allow user to change this password in UI (currently user has to enter previous password)
        password = Digest::MD5.hexdigest("intuit_#{user.email}")
        user.password = user.password_confirmation = password
      end
    end
  end

  # Returns true is an user is connected with Intuit account
  def connected_with_intuit?
    intuit_openid_identifier.present?
  end

  # Returns true if an user is connected with Intuit account and he has no companies.
  # In this case we have to initiate company import process
  def initiate_intuit_company_connect?
    connected_with_intuit? and companies.empty?
  end

end
