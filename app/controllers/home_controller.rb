class HomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_current_user_companies!

  before_filter :redirect_to_app_or_root
  before_filter :check_current_company_intuit_token_validity

  # application
  def index
  end

  def bootstrap
    @periods = Period.all
  end

  private

  # TODO duplicated method
  def check_current_user_companies!
    if current_user.companies.empty?
      sign_out(current_user)
      flash[:error] = 'You do not have any companies.'
      redirect_to new_user_session_url(subdomain: 'launchpad')
    end
  end

  # Displays flash alert about expired QuickBooks token
  def check_current_company_intuit_token_validity
    if current_company.present? and current_company.intuit_token_expired?
      flash.now[:error] = 'QuickBooks token is expired. Please reconnect.'
    end
  end

end
