# Encapsulates logic for QuickBooks
module Company::QuickBooks
  extend ActiveSupport::Concern

  included do
    embeds_one :intuit_company

    with_options to: :intuit_company, prefix: :intuit, allow_nil: true do |intuit|
      intuit.delegate :realm
      intuit.delegate :access_token
      intuit.delegate :access_secret
      intuit.delegate :connected_at

      intuit.delegate :token_expired?
      intuit.delegate :oauth_token
      intuit.delegate :disconnect!
    end
  end

  # Updates company's #name and #subdomain from Intuit company data
  def update_attributes_from_intuit!(external_attributes)
    self.name = external_attributes[:name]

    # Update subdomain
    subdomain = suggested_subdomain
    if self.subdomain != subdomain
      # Append realm do subdomain if subdomain is already taken
      realm = external_attributes[:realm]
      subdomain = "#{subdomain}-#{realm}" if Company.where(subdomain: subdomain).exists?
      self.subdomain = subdomain
    end

    save!
  end

  # Returns true if company is connected to Intuit
  def connected_to_intuit?
    intuit_connected_at.present?
  end

  # Returns true if company was ever connected to Intuit
  def ever_connected_to_intuit?
    intuit_company?
  end

end
