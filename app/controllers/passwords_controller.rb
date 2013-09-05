class PasswordsController < Devise::PasswordsController

  private

  # Overrides Devise redirection after successfull reset password
  def after_sign_in_path_for(user)
    app_url(subdomain: current_company.subdomain)
  end
end
