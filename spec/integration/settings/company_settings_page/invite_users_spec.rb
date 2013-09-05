require 'spec_helper'

feature 'Company settings page', :advisor, js: true do
  let!(:user) { create(:user, email: 'test@user.com', name: 'First User') }
  let!(:first_user) { create(:user, email: 'other@user.com', name: 'Second User') }
  let!(:second_user) { create(:user, email: 'user@other.com') }

  let!(:advisor_company) { create(:advisor_company, name: 'Advisor company') }
  let!(:company) { create(:company, users: [user, first_user]) }

  background do
    login_as(user)
    navigate_to('settings', 'company')
  end

  def invite_by(email)
    within 'form.form-add-user' do
      fill_in 'email', with: email
      click_button 'Invite'
    end
  end

  describe 'invitation form validation' do
    def should_show_validation_error(message)
      within '#company-invitations form .validation-error' do
        page.should have_content(message)
      end
    end

    scenario 'validation error when en email is invalid' do
      invite_by('invalid email')
      should_show_validation_error 'User email is invalid'
    end

    scenario 'validation error when an user is already invited' do
      create(:company_invitation, company: company, email: 'new@user.com')
      
      invite_by('new@user.com')
      should_show_validation_error 'User email is already invited'
    end

    scenario 'validation error when an user is already in the company' do
      invite_by(first_user.email)
      should_show_validation_error 'User is already in the company'
    end
  end

  describe 'invite existing user' do
    scenario 'should add an user to the company' do
      invite_by(second_user.email)

      within '#company-affiliations table.users' do
        page.should have_content(second_user.name)
        page.should have_content(second_user.email)
      end

      affiliation = company.user_affiliations.where(user: second_user).first
      affiliation.should_not be_nil

      second_user.companies.should include(company)
    end
  end

  describe 'invite new user' do
    let(:email) { 'new@user.com' }
    scenario 'should send an invitation' do
      invite_by(email)
      wait_for_ajax_complete

      within '#company-affiliations table.users' do
        page.should_not have_content(email)
      end

      invitations = company.invitations
      invitations.should have(1).item
      invitation = invitations.last
      invitation.email.should == email
    end
  end

end
