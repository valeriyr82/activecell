require 'spec_helper'

feature "Cancel account", :billing, js: true do
  let!(:company) { create(:company) }
  let!(:user) { create(:user, companies: [company], email: 'test@user.com') }

  background do
    login_as(user)
    navigate_to('settings', 'account')
  end

  context 'without subscription' do
    before do
      page.should have_content('You can')
      page.should have_link('cancel')
      page.should have_content('your account')
    end

    context 'user with several companies' do
      let!(:other_company) { create(:company, name: 'Other company', subdomain: 'other', users: [user]) }

      scenario 'click cancel account button' do
        click_link 'cancel'
        confirm_dialog('Are you sure you wish to cancel your account? This cannot be undone.')

        # Should redirect to other company app page
        should_load_application_for(other_company)

        user.reload
        user.companies.should have(1).item
        user.companies.should include(other_company)
      end
    end

    context 'user with only one company' do
      scenario 'click cancel account button' do
        click_link 'cancel'
        confirm_dialog('Are you sure you wish to cancel your account? This cannot be undone.')

        # should log out an user and redirect to login page
        should_load_sign_in_page
        page.should display_flash_message('You do not have any companies.')

        user.reload
        user.companies.should have(0).items
      end
    end
  end

  context 'with active subscription' do
    let(:subscription_uuid) { 'dummy-subscription-uuid' }
    let(:plan_name) { 'Activecell Monthly' }

    background do
      attributes = { uuid: subscription_uuid, plan_name: plan_name,
                     plan_unit_amount_in_cents: 4999, plan_interval_unit: 'months' }
      company.subscription = build(:company_subscription, :active, attributes)
      company.save!
    end

    use_vcr_cassette

    scenario 'click cancel account button' do
      click_link 'cancel'
      confirm_dialog('Are you sure you wish to cancel your account? This cannot be undone.')

      should_load_sign_in_page
      page.should display_flash_message('You do not have any companies.')

      user.reload
      user.companies.should have(0).items
    end
  end
end
