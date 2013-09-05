class RegistrationsController < Devise::RegistrationsController
  before_filter :redirect_to_launchpad, :find_invitation

  def new
    if @invitation
      @sign_up = SignUpForm.from_invitation @invitation
    else
      @sign_up = SignUpForm.new
    end
    @company = @sign_up.company
  end

  def create
    @sign_up = SignUpForm.new(params[:sign_up_form])
    @sign_up.invitation = @invitation
    if @sign_up.save
      user = @sign_up.user
      Notifications.sign_up(@sign_up.company.id, user.email).deliver
      sign_in(user)
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  private
  
  def find_invitation
    unless params[:t].blank?
      @token = params[:t]
      @invitation = CompanyInvitation.find_by(token: @token)
      unless @invitation.is_active?
        return redirect_to new_user_registration_url, flash: {error: 'This invitation is no longer active, sorry.'}
      end
    end
  end
end
