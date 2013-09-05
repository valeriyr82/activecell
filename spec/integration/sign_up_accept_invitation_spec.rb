require 'spec_helper'

feature 'Sign up with invitation token', :auth, js: true do

  describe 'with inactive invitation' do
    let!(:invitation) { create(:company_invitation, is_active: false) }

    background do
      visit "/users/sign_up?t=#{invitation.token}"
    end

    scenario 'displays alert flash message' do
      page.should display_flash_message('no longer active')
    end

    scenario 'should have no token in url anymore' do
      page.current_path.should_not include invitation.token
    end
  end

  describe 'with active invitation' do
    let!(:invitation) { create(:company_invitation) }

    background do
      visit "/users/sign_up?t=#{invitation.token}"
    end

    # TODO fields are not set to read-only
    it 'an user can see the sign in form with some fields readonly' do
      page.should have_css('#sign_up_form_company_name[readonly]')
      page.should have_css('#sign_up_form_company_subdomain[readonly]')
      page.should have_css('#sign_up_form_user_email[readonly]')
    end

    describe 'when user fills remaining fields with valid values' do
      background do
        within 'form' do
          fill_in 'sign_up_form_user_name', with: 'John'
          fill_in 'sign_up_form_user_password', with: 'password1'
          fill_in 'sign_up_form_user_password_confirmation', with: 'password1'
        end
      end

      scenario 'he should be logged in' do
        click_button 'Sign up'
        within 'div.container' do
          page.should have_content(invitation.email)
        end
        current_path.should == root_path
      end

      scenario 'create an user and a company affiliation' do
        expect do
          click_button 'Sign up'
          wait_until { within('.head-buttons') { page.has_button?(invitation.company.name) } }
        end.not_to change(Company, :count)

        user = User.find_by_email(invitation.email)
        user.valid_password?('password1').should be_true

        company = user.first_company
        company.should be_present
        company.name.should == invitation.company.name

        should_load_application_for(company)
      end

      scenario 'mark invitation as inactive' do
        expect do
          click_button 'Sign up'
          wait_until { within('.head-buttons') { page.has_button?(invitation.company.name) } }
          invitation.reload
        end.to change(invitation, :is_active).from(true).to(false)
      end
    end

    describe 'when user fills remaining fields with invalid values' do
      background do
        within 'form' do
          fill_in 'sign_up_form_user_password', with: 'password1'
          fill_in 'sign_up_form_user_password_confirmation', with: 'NOWAY!!!'
        end
      end

      scenario 'he should see validation errors but only related to user' do
        click_button 'Sign up'

        within '#error_explanation' do
          page.should have_no_content("6 errors prohibited this user from being saved")
          page.should have_content("2 errors prohibited this user from being saved")
          page.should have_no_content("Company name can't be blank")
          page.should have_no_content("Company subdomain is too short (minimum is 1 characters)")
          page.should have_content("User name can't be blank")
          page.should have_no_content("User email is invalid")
          page.should have_content("User password doesn't match confirmation")
        end
      end
    end
  end
end
