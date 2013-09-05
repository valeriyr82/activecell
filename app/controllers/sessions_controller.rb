class SessionsController < Devise::SessionsController
  skip_before_filter :require_no_authentication, only: [:new, :create]
  before_filter :check_current_user_companies!, only: [:new, :create]
  before_filter :redirect_to_launchpad, only: [:new, :create]

  private

  # TODO duplicated method
  def check_current_user_companies!
    if current_user.present? and current_user.companies.empty?
      sign_out(current_user)
      flash[:error] = 'You do not have any companies.'
      redirect_to new_user_session_url(subdomain: 'launchpad')
    else
      require_no_authentication
    end
  end

  # Overrides Devise redirection after successfull login
  # When user attempts to login via UserVoice he will be redirected
  def after_sign_in_path_for(user)
    if resource_params[:uv_login].present?
      # Redirect to UserVoice with sso token
      user_voice_url(user)
    else
      # ..just redirect to the app
      app_url(subdomain: current_company.subdomain)
    end
  end

  # Overrides DeviseController#resource_params method
  # It reads params[:uv_login] and if it present sets User#uv_login attribute
  def resource_params
    user_params = params[:user] || {}
    user_params.merge!(uv_login: params[:uv_login]) if params[:uv_login].present?
    user_params
  end
end
