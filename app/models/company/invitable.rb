# Encapsulates logic for
# * inviting users to the company
# * inviting other companies as advisors
# * inviting advised companies
module Company::Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, class_name: 'CompanyInvitation', inverse_of: :company, dependent: :destroy
  end

  def invite_user_by_email(email)
    user = User.find_by_email(email)
    if user.present?
      invite_user(user)
    else
      create_invitation_for(email)
    end
  end

  # Invite an user to the company
  def invite_user(user)
    user_affiliations.create(user_id: user.id)
  end

  def create_invitation_for(email)
    invitations.create(email: email)
  end

  # Invite other company as an advisor
  def invite_advisor(advisor_company)
    advisor_company.become_an_advisor_for(self)
  end

end
