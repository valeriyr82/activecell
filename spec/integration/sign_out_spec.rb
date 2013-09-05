require 'spec_helper'

feature 'Sign out', :auth, js: true do
  let!(:company) { create(:company) }
  let!(:user) { create(:user, companies: [company], email: 'user@email.com') }

  background do
    login_as(user)
    visit root_path

    within '#user-settings-menu' do
      click_button(user.email)
      click_link('Log out')
    end
  end

  scenario 'successfully sign out' do
    page.should have_content('Log in')
    current_path.should == new_user_session_path
  end
end
