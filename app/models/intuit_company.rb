class IntuitCompany
  include Mongoid::Document

  PROVIDERS = %w(QBD QBO)

  field :realm, type: Integer
  field :access_token, type: String
  field :access_secret, type: String
  field :provider, type: String
  field :connected_at, type: Time

  embedded_in :company

  validates :realm, presence: true, uniqueness: true
  validates :provider, presence: true, inclusion: {in: PROVIDERS}

  index({ realm: 1 })

  class << self
    def find_by_realm(realm)
      where(realm: realm)
    end
  end

  # Returns true if company was connected to Intuit more than 6 months ago
  # @see https://ipp.developer.intuit.com/0010_Intuit_Partner_Platform/0025_Intuit_Anywhere/2000_Developing_Your_App/0600_OAuth_for_IA/Token_Expiration
  def token_expired?
    connected_at? and connected_at < 6.months.ago
  end

  # Disconnect company from Intuit account
  def disconnect!
    attributes = { access_token: nil, access_secret: nil, connected_at: nil }
    update_attributes(attributes)
  end

  # Returns the Access Token for the given Company
  # it can be used for performing webservice calls against the Intuit server
  def oauth_token
    @oauth_token ||= OAuth::AccessToken.new(oauth_consumer, access_token, access_secret)
  end

  private

  # Returns OmniAuth consumer for Intuit strategy
  def oauth_consumer
    Intuit::Api.consumer
  end
end
