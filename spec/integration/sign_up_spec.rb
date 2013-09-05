require 'spec_helper'

feature 'Sign up', :auth, js: true do
  background do
    visit new_user_registration_path
  end

  scenario 'an user can see the sign in form' do
    page.should have_content('Sign in')

    within 'form' do
      page.should have_field('sign_up_form_company_name')
      page.should have_field('sign_up_form_company_subdomain')

      page.should have_field('sign_up_form_user_name')
      page.should have_field('sign_up_form_user_email')
      page.should have_field('sign_up_form_user_password')
      page.should have_field('sign_up_form_user_password_confirmation')

      page.should have_button('Sign up')
    end
  end

  describe 'form submit 'do
    background do
      within 'form' do
        fill_in 'sign_up_form_company_name', with: company_name
        fill_in 'sign_up_form_company_subdomain', with: company_subdomain
        fill_in 'sign_up_form_user_name', with: name
        fill_in 'sign_up_form_user_email', with: email
        fill_in 'sign_up_form_user_password', with: password
        fill_in 'sign_up_form_user_password_confirmation', with: password_confirmation
      end
    end

    describe 'when the user provides valid credentials' do
      let(:company_name) { 'Sterling Cooper' }
      let(:company_subdomain) { 'sterling-cooper-domain' }
      let(:name) { 'Sample User' }
      let(:email) { 'new@user.com' }
      let(:password) { 'secret-password' }
      let(:password_confirmation) { password }

      scenario 'he should be logged in' do
        click_button 'Sign up'

        within 'div.container' do
          page.should have_content(email)
        end
        current_path.should == root_path
      end

      scenario 'create an user along with company' do
        expect do
          click_button 'Sign up'
          wait_until { within('.head-buttons') { page.has_button?(company_name) } }
        end.to change(Company, :count).by(1)

        user = User.find_by_email(email)
        user.valid_password?(password).should be_true

        company = user.first_company
        company.should be_present
        company.name.should == company_name

        should_load_application_for(company)
      end
    end

    describe 'when the user provides invalid credentials' do
      let(:company_name) { '' }
      let(:company_subdomain) { '' }
      let(:name) { '' }
      let(:email) { 'invalid.email' }
      let(:password) { 'foo' }
      let(:password_confirmation) { 'bar' }

      scenario 'he should see validation errors' do
        click_button 'Sign up'

        within '#error_explanation' do
          page.should have_content("6 errors prohibited this user from being saved")
          page.should have_content("Company name can't be blank")
          page.should have_content("Company subdomain is too short (minimum is 1 characters)")
          page.should have_content("User name can't be blank")
          page.should have_content("User email is invalid")
          page.should have_content("User password doesn't match confirmation")
          page.should have_content("User password is too short (minimum is 6 characters)")
        end
      end

      scenario 'should not create an user' do
        expect do
          click_button 'Sign up'
        end.not_to change(User, :count)
      end
    end
  end
end
