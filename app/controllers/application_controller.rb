class ApplicationController < ActionController::Base
  include UrlHelper
  protect_from_forgery

  helper_method :current_company, :current_subscriber, :current_scenario
  helper_method :user_voice_url

  before_filter :check_company_subdomain!

  private

  def current_company
    @company ||= current_company_resolver.resolve
  end

  def current_scenario
    @scenario ||= current_company.current_scenario(session[:scenario_id])
  end

  def current_company_resolver
    @current_company_resolver ||= CurrentCompanyResolver.new(current_subdomain, current_user)
  end

  # Returns the current subdomain
  def current_subdomain
    SubdomainResolver.current_subdomain_from(request)
  end

  def current_subscriber
    @subscriber ||= current_company.subscriber if current_company.present?
  end

  # Redirects to the launchpad page if an user does not have an access to the given
  # company's subdomain
  def check_company_subdomain!
    sign_in_demo

    subdomain_resolver = SubdomainResolver.new(current_subdomain, current_user)
    redirect_to_launchpad if subdomain_resolver.not_belongs_to_user?
  end

  # Use in all not app actions as default way for redirect.
  # When user logged in he should always works with app in root url '/'
  # In other cases he should works in 'launchpad' subdomain.
  def redirect_to_app_or_root
    sign_in(User.demo_take) if !user_signed_in? && Rails.env.demo?

    if user_signed_in? and current_company.present?
      redirect_to_app
    else
      redirect_to_launchpad
    end
  end

  def redirect_to_app
    return if on_current_company_subdomain?

    flash.keep
    redirect_to subdomain: current_company.subdomain
  end

  def redirect_to_launchpad
    return if on_launchpad_subdomain?

    flash.keep
    redirect_to params.merge(subdomain: 'launchpad')
  end

  def on_launchpad_subdomain?
    current_subdomain == 'launchpad'
  end

  def on_current_company_subdomain?
    current_subdomain == current_company.subdomain
  end

  def sign_in_demo
    sign_in(User.demo_take) if Rails.env.demo? and not user_signed_in?
  end

  # Generates an url to UserVoice site
  # If an user is signed in it appends sso token
  def user_voice_url(user = current_user)
    url = "http://support.activecell.com"
    url << "/login_success?sso=#{CGI.escape(user.uv_sso_token)}" if user.present?
    url
  end
end
