require 'spec_helper'

feature 'Company settings page', :branding, js: true do
  let!(:company) { create(:company) }
  let!(:user) { create(:user, companies: [company], email: 'test@user.com') }

  describe 'when the branding is overridden' do
    let!(:advisor_company) { create(:advisor_company, users: [user]) }
    before do
      advisor_company.become_an_advisor_for(company)
      advisor_company.override_branding_for(company)
    end

    background do
      login_as(user)
      navigate_to('settings', 'company')
    end

    scenario 'it should hide logo upload form' do
      page.should_not have_css('.company-logo-inner')
    end
  end

  describe 'upload logo' do
    background do
      login_as(user)
      navigate_to('settings', 'company')
    end

    scenario 'upload a valid logo' do
      page.should have_content("upload company logo")
      attach_file('company_logo', "#{Rails.root}/spec/fixtures/sample_logo.png")
      wait_for_ajax_complete

      company.reload

      within '#header' do
        page.should have_xpath("//img[@src=\"#{company.branding.logo.url(:resized)}\"]")
      end

      within '.company-logo-inner' do
        page.should have_xpath("//img[@src=\"#{company.branding.logo.url(:resized)}\"]")
        page.should have_content('clear logo')
      end

      visit root_path

      within '#header' do
        page.should have_xpath("//img[@src=\"#{company.branding.logo.url(:resized)}\"]")
      end
    end

    scenario 'upload a invalid logo format' do
      page.should have_content("upload company logo")
      attach_file('company_logo', "#{Rails.root}/spec/integration/settings/company_settings_page_spec.rb")

      within '.company-logo-section' do
        page.should have_content("must be in 'png/jpg/jpeg/gif' format")
      end
    end
  end

  describe 'revert logo' do
    background do
      company.branding.logo = File.new("#{Rails.root}/spec/fixtures/sample_logo.png")
      company.save

      login_as(user)
      navigate_to('settings', 'company')
    end

    scenario 'always revert logo successfully' do
      within '.company-logo-inner' do
        page.should have_content('clear logo')
        click_link 'clear logo'
      end

      within '#header' do
        page.should have_xpath("//img[@src='#{CompanyBranding::DEFAULT_LOGO_URL}']")
      end

      within '.company-logo-inner' do
        page.should have_xpath("//img[@src=\"/assets/placeholder_logo.png\"]")
      end

      visit root_path

      within '#header' do
        page.should have_xpath("//img[@src='#{CompanyBranding::DEFAULT_LOGO_URL}']")
      end
    end
  end

end
