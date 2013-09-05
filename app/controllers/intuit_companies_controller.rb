class IntuitCompaniesController < ApplicationController

  # Intuit company connection callback
  def callback
    realm_id = params[:realmId] || auth_hash_credentials[:realmId]
    attributes = {
        access_token: auth_hash_credentials[:token],
        access_secret: auth_hash_credentials[:secret],
        realm: realm_id,
        provider: params[:dataSource] || auth_hash_credentials[:dataSource],
        connected_at: Time.now
    }

    if current_company.present?
      ## Connect the current company with Intuit

      if current_company.create_intuit_company(attributes)
        flash[:info] = 'Company has been connected.'
      end

      redirect_to app_url(subdomain: current_company.subdomain)
    else
      ## Import company from Intuit account

      # Create a new company with temporary name and subdomain
      company = Company.new do |c|
        c.name = "intuit-#{realm_id}"
        c.subdomain = "intuit-#{realm_id}"
      end
      company.build_intuit_company(attributes)
      company.save!
      company.invite_user(current_user)

      # Update company name and subdomain from Intuit
      token = company.intuit_oauth_token
      response = token.get("https://services.intuit.com/sb/company/v2/availableList")

      external_attributes = Intuit::AvailableListXmlParser.new(response.body).find_by_realm(realm_id)
      company.update_attributes_from_intuit!(external_attributes)

      flash[:info] = 'Company has been created.'
      redirect_to app_url(subdomain: company.subdomain, anchor: 'settings/data_integrations')
    end
  end

  # Proxy for BlueDot menu
  def proxy
    token = current_company.intuit_oauth_token
    response = token.get("https://appcenter.intuit.com/api/v1/Account/AppMenu")

    render :text => response.body, :status => response.code
  end

  # Disconnect company from Intuit account
  def disconnect
    token = current_company.intuit_oauth_token
    token.get("https://appcenter.intuit.com/api/v1/Connection/Disconnect")

    if current_company.intuit_disconnect!
      flash[:info] = 'Company has been disconnected.'
    end

    redirect_to app_url(subdomain: current_company.subdomain, anchor: 'settings/data_integrations')
  end

  private

  def auth_hash
    ActiveSupport::HashWithIndifferentAccess.new(request.env['omniauth.auth'])
  end

  def auth_hash_credentials
    auth_hash[:credentials]
  end

end
