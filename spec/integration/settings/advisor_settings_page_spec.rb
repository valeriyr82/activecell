require 'spec_helper'

feature 'Advisor settings page', :advisor, js: true do
  include_context 'advisor settings page'

  background do
    login_as(user)
    navigate_to('settings', 'advisor')
  end

  # TODO write scenario for checking whether advisor menu items are hidden

  scenario 'display a list of advised companies' do
    within '.main-content' do
      page.should have_content('Advisor Settings')
      page.should have_content('Companies you advise')

      page.should have_selector('table tbody tr', count: 3)

      within_row_for(first_affiliation) do
        page.should have_content(first_advised_company.name)
      end

      within_row_for(second_affiliation) do
        page.should have_content(second_advised_company.name)
      end

      within_row_for(third_affiliation) do
        page.should have_content(third_advised_company.name)
      end
    end
  end

  context 'create a new company'  do
    it_behaves_like 'quick company creation', number_of_displayed_companies: 4
  end
end
