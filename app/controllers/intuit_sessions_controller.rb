class IntuitSessionsController < ApplicationController

  def callback
    email = auth_hash[:info][:email]
    user = User.find_by_email(email)

    if user.present?
      user.update_attribute(:intuit_openid_identifier, auth_hash[:uid]) unless user.connected_with_intuit?

      sign_in(user)
      flash[:info] = 'Logged in via Intuit SSO'
    else
      new_user = User.new_from_auth_hash(auth_hash)
      new_user.save!

      sign_in(new_user)
      flash[:info] = 'New user logged in via Intuit SSO.'
    end

    if current_user.initiate_intuit_company_connect?
      # If an user does not have any companies but it comes from intuit sso
      # ..initiate company connect process
      redirect_to '/auth/intuit'
    else
      # ..just redirect to the app
      redirect_to app_url(subdomain: current_user.first_company.subdomain)
    end
  end

  def failure
    flash[:error] = 'Error while sign in.'
    redirect_to new_user_session_url(subdomain: 'launchpad')
  end

  private

  def auth_hash
    ActiveSupport::HashWithIndifferentAccess.new(request.env['omniauth.auth'])
  end

end
