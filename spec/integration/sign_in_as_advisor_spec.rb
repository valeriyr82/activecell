require 'spec_helper'

feature 'Sign in as an advisor', :auth, :advisor, js: true do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:company) { create(:company, name: 'First company') }
  let!(:advisor_company) { create(:advisor_company, name: 'Advisor company') }

  context 'when an user has only one company' do
    background do
      company.invite_user(user)
      login_as(user)
    end

    scenario 'display only one company in the company select box' do
      should_load_application_for(company)
    end
  end

  context 'when an user has two companies' do
    background do
      company.invite_user(user)
      advisor_company.invite_user(user)
      login_as(user)
    end

    scenario 'display two company in the company select box' do
      should_load_application_for(company)

      click_button 'First company'
      within 'ul.companies' do
        page.should have_content('First company')
        page.should have_content('Advisor company')
      end
    end
  end

  context 'when an user belongs to one company as an advisor' do
    let!(:other_company) { create(:company, name: 'Advised company') }

    background do
      company.invite_user(user)
      advisor_company.invite_user(user)
      other_company.invite_advisor(advisor_company)
      login_as(user)
    end

    scenario 'display advised companies' do
      navigate_to('settings', 'user')

      within 'table.companies' do
        page.should have_content('First company')
        page.should have_content('Advisor company')
      end
    end
  end

end
