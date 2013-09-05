class Api::BaseController < ApplicationController
  respond_to :json
  helper_method :filter_params!

  before_filter :auth!
  before_filter :check_trial_period!
  skip_before_filter :check_company_subdomain!

  class Api::SecurityError < StandardError; end

  rescue_from Mongoid::Errors::DocumentNotFound, Api::SecurityError do
    respond_with({ error: 'Document(s) not found.' }, status: :not_found)
  end

  private

  # If user does not authorized returns 403 (forbidden)
  # Option location: new_user_session_path uses for force redirect
  def auth!
    return if user_signed_in?

    unless basic_http_auth!
      respond_with({}, location: new_user_session_path, status: :forbidden)
    end
  end

  # Perform basic http authentication for the API call
  def basic_http_auth!
    return false unless request.authorization.present?

    email, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request)
    user = User.find_by_email(email)

    if user.present? and user.valid_password?(password)
      sign_in(user)
      true
    else
      false
    end
  end

  # TODO document it, think about sth more solid, for instance strong_parameters from Rails 4
  def filter_params!(field_name = controller_name)
    model_name = controller_name
    params[model_name] = { field_name.to_s => params[model_name][field_name] }
  end

  def check_trial_period!
    # TODO naughty bug, I'm not sure why I can't use current_company here
    company = CurrentCompanyResolver.new(current_subdomain, current_user).resolve
    if company.present? and company.trial_expired?
      respond_with({ error: 'Trial period expired' }, status: :payment_required)
    end
  end
end
