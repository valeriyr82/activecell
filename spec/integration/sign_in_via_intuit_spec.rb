require 'spec_helper'

feature 'Sign in via Intuit', :auth, :intuit, js: true do
  background { visit root_path }

  describe 'when authentication fails' do
    background do
      OmniAuth.config.mock_auth[:intuit_sso] = :invalid_credentials
    end

    scenario 'display error message' do
      click_link 'Sign in with Intuit'
      page.should have_content('Error while sign in.')
    end
  end

  context 'when an user has the account' do
    let!(:company) { create(:company, name: 'Intuit company') }
    let!(:user) { create(:user, companies: [company], email: 'test@user.com') }

    let(:intuit_openid_identifier) { 'https://openid.intuit.com/Identity-232840dc-9d6f-447d-a74a-5341f6598ac3' }

    background do
      OmniAuth.config.mock_auth[:intuit_sso] = {
          provider: 'intuit_sso',
          uid: intuit_openid_identifier,
          info: {
              email: 'test@user.com'
          }
      }
    end

    scenario 'sign in successfully' do
      click_link 'Sign in with Intuit'
      page.should have_content('Intuit company')
    end

    scenario 'update intuit openid identifier' do
      click_link 'Sign in with Intuit'
      user.reload

      uid = user.intuit_openid_identifier
      uid.should_not be_nil
      uid.should == intuit_openid_identifier
    end
  end

  context 'when an user does not have the account' do
    use_vcr_cassette

    let(:intuit_openid_identifier) { 'https://openid.intuit.com/Identity-232840dc-9d6f-447d-a74a-5341f6598ac3' }
    let(:email) { 'new@user.com' }
    let(:name) { 'Test User' }

    background do
      OmniAuth.config.mock_auth[:intuit_sso] = {
          provider: 'intuit_sso',
          uid: intuit_openid_identifier,
          info: {
              email: email,
              name: name
          }
      }

      OmniAuth.config.mock_auth[:intuit] = {
          provider: 'intuit',
          credentials: {
              dataSource: 'QBO',
              realmId: '667',
              token: 'new auth token',
              secret: 'new auth secret'
          }
      }
    end

    scenario 'create an user account along wit company and sign in' do
      click_link 'Sign in with Intuit'

      new_user = User.find_by_email(email)
      new_user.should_not be_nil
      new_user.intuit_openid_identifier.should == intuit_openid_identifier
      new_user.email.should == email
      new_user.name.should == name
      new_user.valid_password?(Digest::MD5.hexdigest("intuit_#{email}")).should be_true

      company = new_user.companies.last
      company.should_not be_nil
      company.name.should == 'Company from Intuit'
      company.subdomain.should == 'company-from-intuit'

      intuit_company = company.intuit_company
      intuit_company.should_not be_nil
      intuit_company.realm.should == 667
      intuit_company.access_token.should == 'new auth token'
      intuit_company.access_secret.should == 'new auth secret'
      intuit_company.connected_at.should <= Time.now

      page.should display_flash_message('Company has been created.')
    end
  end

end
