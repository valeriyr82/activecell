require 'spec_helper'

feature 'User settings page', js: true do
  let!(:user) { create(:user, email: 'test@user.com', password: 'secret password') }
  let!(:company) { create(:company, name: 'First company', users: [user]) }

  background do
    login_as(user, password: 'secret password')
    navigate_to('settings', 'user')
  end

  describe 'change password form' do
    let(:new_password) { 'new password' }

    scenario 'an user can see the form' do
      within 'h5' do
        page.should have_content('Need to reset your password?')
      end

      within 'form#user-password-form' do
        page.should have_field('user_current_password')
        page.should have_field('user_password')
        page.should have_field('user_password_confirmation')
      end
    end

    scenario 'change password' do
      within 'form#user-password-form' do
        fill_in 'user_current_password', with: 'secret password'
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password

        click_button 'Change password'
      end

      # Wait until notification is displayed
      within 'form#user-password-form' do
        wait_until { page.has_css?('.password-changed-notification', visible: true) }
        page.should have_content('Password was changed.')
      end

      # should change the password
      user.reload
      user.valid_password?(new_password).should be_true

      # Log in again
      logout user

      within 'form#new_user' do
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: new_password

        click_button 'login_button'
      end

      should_load_application_for(company)
    end

    scenario 'change password validation errors' do
      within 'form#user-password-form' do
        fill_in 'user_current_password', with: 'invalid password'
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: 'other password'

        click_button 'Change password'

        page.should have_content("is invalid")
        page.should have_content("doesn't match confirmation")
      end
    end
  end
end
