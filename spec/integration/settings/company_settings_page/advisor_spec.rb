require 'spec_helper'

feature 'Company settings page', :advisor, js: true do
  let!(:user) { create(:user, email: 'test@user.com', name: 'First User') }
  let!(:company) { create(:company, users: [user]) }
  let(:is_an_advisor) { false }

  background do
    company.upgrade_to_advisor! if is_an_advisor
  end

  def visit_company_setting_page
    login_as(user)
    navigate_to('settings', 'company')
  end

  describe 'update to advisor company' do
    before { visit_company_setting_page }

    scenario 'should hide "Advisor Settings" in the user settings menu' do
      within 'ul.sub-nav' do
        page.should_not have_link('advisor')
      end
    end

    scenario 'display advisor box' do
      within '#advisor-box' do
        page.should have_content("Does #{company.name} advise other businesses?")
        page.should have_content("If so, we can upgrade you to Advisor status and help deploy Profitably to your clients!")
        page.should have_link('Get Started')
      end
    end

    scenario 'click "Get Started" button' do
      within '#advisor-box' do
        click_link 'Get Started'
      end

      # should redirect to the Advisor Settings page
      wait_until { page.has_content?('Advisor Settings') }

      upgraded_company = Company.find(company.id)
      upgraded_company.should be_an_instance_of(AdvisorCompany)
    end
  end

  context 'when the company is an advisor' do
    let(:is_an_advisor) { true }
    before { visit_company_setting_page }

    scenario 'should show "Advisor Settings" in the user settings menu' do
      within 'ul.sub-nav' do
        page.should have_link('advisor')
      end
    end

    scenario 'display advisor box' do
      within '#advisor-box' do
        page.should have_content("You're an advisor!")
        page.should have_link('Downgrade')
      end
    end

    scenario 'click "Downgrade" button' do
      within '#advisor-box' do
        click_link 'Downgrade'
        page.should have_link('Get Started')
      end

      downgraded_company = Company.find(company.id)
      downgraded_company.should be_an_instance_of(Company)
    end
  end

  context 'when the company is already advised' do
    let!(:advisor_company) { create(:advisor_company) }
    before do
      company.invite_advisor(advisor_company)
      visit_company_setting_page
    end

    scenario 'advisor box should not be visible' do
      page.should_not have_css('#advisor-box')
    end
  end
end
