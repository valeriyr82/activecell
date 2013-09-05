class Notifications < AsyncMailer
  add_template_helper(GravatarHelper)
  before_filter :add_inline_attachments!

  def sign_up(company_id, email)
    @company = Company.find(company_id)

    mail to: email, subject: 'welcome to activecell'
  end
  
  def company_invitation(invitation_id)
    @invitation = CompanyInvitation.find(invitation_id)
    @registration_url = new_user_registration_url(:t => @invitation.token)

    mail to: @invitation.email, subject: 'you were invited to activecell'
  end

  # Notify about activity stream creation
  def activity_created(activity_id, user_id)
    @activity = Activity.find(activity_id)
    @user = User.find(user_id)
    @created_by = @activity.user

    # TODO: populate the subject with a formatted version of the content/sender
    mail to: @user.email, subject: 'a message from activecell'
  end

  # Notify about task creation
  def task_created(task_id, user_id)
    @task = Task.find(task_id)
    @user = User.find(user_id)
    @created_by = @task.user

    mail to: @user.email, subject: 'an activecell task was assigned to you'
  end

  # Notify about task completion
  def task_completed(task_id, user_id)
    @task = Task.find(task_id)
    @user = User.find(user_id)
    @created_by = @task.user

    mail to: @user.email, subject: 'an activecell task was just completed'
  end

  private

  def add_inline_attachments!
    image_path = 'branding/style_guide/logo/activecell-full-color-darkBG-small.png'
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/#{image_path}")
  end

end
