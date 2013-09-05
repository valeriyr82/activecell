require 'spec_helper'

feature 'Sign in', :auth, js: true do
  background { visit root_path }

  scenario 'an user can see the sign in form' do
    should_load_sign_in_page
  end

  context 'user does not have an account' do
    background { login_with('foo@bar.com', password: 'abrakadabra') }

    scenario "unregistered user can't login" do
      page.should have_content('Invalid email or password.')
      current_path.should == new_user_session_path
    end
  end

  context 'user does not belong to any company' do
    let!(:user) { create(:user) }
    background { login_as(user) }

    scenario "user without companies can't login" do
      page.should display_flash_message('You do not have any companies.')
      current_path.should == new_user_session_path
    end
  end

  context 'user has an account' do
    let!(:company) { create(:company) }
    let!(:user) { create(:user, companies: [company]) }

    describe 'when an user provides valid credentials' do
      background do
        fill_in 'user_email', :with => user.email
        fill_in 'user_password', :with => 'password'
        click_button 'Log in'
      end

      scenario 'he should be logged in' do
        within 'div.container' do
          page.should have_content(user.email)
        end

        within '#user-settings-menu' do
          click_button(user.email)
          page.should have_link('Log out')
        end
      end

      scenario 'he should be redirected to his company' do
        should_load_application_for(company)
      end

      scenario 'he should be able to log out' do
        within '#user-settings-menu' do
          click_button(user.email)
          click_link('Log out')
        end

        page.should have_content('Sign in')
      end
    end
  end
end
