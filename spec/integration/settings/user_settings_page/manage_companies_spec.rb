require 'spec_helper'

feature 'User settings page', js: true do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:other_user) { create(:user, email: 'other@user.com') }

  let!(:company) { create(:company, name: 'First company', users: [user]) }
  let!(:second_company) { create(:company, name: 'Second company', users: [user, other_user]) }
  let!(:other_company) { create(:company, name: 'Other company') }

  background do
    login_as(user)
    navigate_to('settings', 'user')
  end

  scenario 'list companies' do
    # should display two companies
    within '#user-companies' do
      page.should have_selector('table tbody tr', :count => 2)

      page.should have_content('First company')
      page.should have_content('Second company')
      page.should_not have_content('Other company')
    end
  end

  describe 'remove company' do
    def click_remove_button_for(company)
      within 'table.companies' do
        within("tr.company-#{company.id}") { click_link 'Remove' }
        confirm_dialog
        wait_until { page.has_no_content?(company.name) rescue true }
      end
    end

    scenario 'remove second company' do
      click_remove_button_for(second_company)

      user.reload
      user.companies.should_not include(second_company)
    end

    scenario 'remove the current company' do
      click_remove_button_for(company)

      should_load_application_for(second_company)

      user.reload
      user.companies.should_not include(company)
      user.companies.should include(second_company)
    end
  end
  
  describe 'create company' do
    it_behaves_like 'quick company creation', number_of_displayed_companies: 3
  end
  
  scenario 'switch company' do
    within "table.companies tr.company-#{second_company.id}" do
      click_link 'Log on'
    end
    should_load_application_for(second_company)
  end

end
