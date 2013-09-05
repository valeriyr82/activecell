require 'spec_helper'

feature 'Data integrations page', :intuit, js: true do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:company) { create(:company, name: 'First company', users: [user]) }

  let(:oauth_token) { 'auth token' }
  let(:oauth_secret) { 'auth secret' }

  background do
    OmniAuth.config.mock_auth[:intuit] = {
        provider: 'intuit',
        credentials: {
            dataSource: 'QBO',
            realmId: '666',
            token: oauth_token,
            secret: oauth_secret
        }
    }

    login_as(user)
    navigate_to('settings', 'integrations')
  end

  describe 'connect with intuit' do
    context 'when the company is not connected' do
      scenario 'display connect button' do
        page.should have_link('Connect with QuickBooks', href: '/auth/intuit')
      end

      scenario 'connect with intuit' do
        click_link 'Connect with QuickBooks'

        should_load_application_for(company)

        company.reload
        intuit_company = company.intuit_company
        intuit_company.should_not be_nil
        intuit_company.access_token.should == 'auth token'
        intuit_company.access_secret.should == 'auth secret'
        intuit_company.realm.should == 666
        intuit_company.connected_at.should_not be_nil
        intuit_company.connected_at.should <= Time.now

        navigate_to('settings', 'integrations')
        page.should_not have_link('Connect with QuickBooks')
        page.should have_content('Company is connected with Intuit')

        # Should display bluedot menu
        page.should have_css('#intuitPlatformAppMenu')
      end
    end
  end

  describe 'bluedot menu' do
    use_vcr_cassette

    context 'when the company is not connected' do
      scenario 'is not displayed' do
        page.should_not have_css('#intuitPlatformAppMenu')
      end
    end

    context 'when the company is connected' do
      background do
        create(:intuit_company, company: company)
        reload_app
      end

      scenario 'is displayed' do
        page.should have_css('#intuitPlatformAppMenu')

        within '#intuitPlatformAppMenu' do
          click_link 'intuitPlatformAppMenuLogo'
          page.should have_content('fancy content for the Bluedot menu')
        end
      end
    end
  end

  describe 'disconnect' do
    context 'when the company is connected' do
      background do
        create(:intuit_company, company: company)
        reload_app
      end

      scenario 'click disconnect button' do
        click_link 'Disconnect from Intuit'
        page.should display_flash_message('Company has been disconnected.')

        company.reload
        company.connected_to_intuit?.should be_false

        intuit_company = company.intuit_company
        intuit_company.access_token.should be_nil
        intuit_company.access_secret.should be_nil
        intuit_company.connected_at.should be_nil

        page.should_not have_css('#intuitPlatformAppMenu')
      end
    end
  end

  describe 'when company access token is expired' do
    let(:oauth_token) { 'new auth token' }
    let(:oauth_secret) { 'new auth secret' }

    before do
      create(:intuit_company, :with_expired_token, company: company)
      reload_app
    end

    scenario 'displays alert flash message' do
      page.should display_flash_message('QuickBooks token is expired. Please reconnect.')
    end

    describe 'reconnect' do
      background do
        navigate_to('settings', 'integrations')
      end

      scenario 'display reconnect button' do
        page.should have_content('QuickBooks token is expired. Please reconnect.')
        page.should have_link('Reconnect with Intuit', href: '/auth/intuit')
      end

      scenario 'click reconnect button' do
        click_link 'Reconnect with Intuit'

        should_load_application_for(company)

        page.should have_content('Company has been connected.')

        company.reload
        intuit_company = company.intuit_company
        intuit_company.should_not be_nil
        intuit_company.access_token.should == 'new auth token'
        intuit_company.access_secret.should == 'new auth secret'
        intuit_company.realm.should == 666
        intuit_company.connected_at.should_not be_nil
        intuit_company.connected_at.should <= Time.now

        navigate_to('settings', 'integrations')
        page.should_not have_link('Reconnect with Intuit')
        page.should have_content('Company is connected with Intuit')

        # Should display bluedot menu
        page.should have_css('#intuitPlatformAppMenu')
      end
    end
  end
end
