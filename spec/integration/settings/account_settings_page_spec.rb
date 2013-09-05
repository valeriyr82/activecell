require 'spec_helper'

feature "Account settings page", :billing, :advisor, js: true do
  let(:subscription_uuid) { 'dummy-subscription-uuid' }
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:company) { create(:company, users: [user]) }

  background { login_as(user) }

  context 'without active subscription' do
    background do
      navigate_to('settings', 'account')
      stub_recurly_jsonp_calls(token: '99624fdb4af045eda32aa051dcfcc394')
    end

    def fill_in_subscription_form
      within '.contact_info' do
        find('.field.first_name input').set('Lukasz')
        find('.field.last_name input').set('Bandzarewicz')
        find('.field.email input').set('test@user.com')
      end

      within '.billing_info' do
        find('.field.card_number input').set('4111 1111 1111 1111')
        find('.field.cvv input').set('111')

        within '.address' do
          find('.field.address1 input').set('Blich 3/7')
          find('.field.city input').set('Krakow')
          find('.field.state input').set('molopolskie')
          find('.field.zip input').set('30-000')
        end
      end
    end

    def should_create_company_subscription(options = {})
      current_path.should == root_path

      page.should have_content('Subscription was successfully created!')
      should_load_application_for(company)

      # should update company's subscription uuid field
      company.reload
      company_subscription = company.subscription

      company_subscription.should be_present
      company_subscription.uuid.should_not be_nil
      company_subscription.uuid.should == '196e14ed332b3aadd6b9374060afdf6f'
      company_subscription.plan_code.should == options[:plan_code]
      company_subscription.plan_name.should == options[:plan_name]
      company_subscription.plan_interval_unit.should == options[:plan_interval_unit]
      company_subscription.plan_interval_length.should == options[:plan_interval_length]
      company_subscription.trial_ends_at.should == options[:trial_ends_at]
      company_subscription.plan_unit_amount_in_cents.should == 4999
    end

    describe 'monthly subscription' do
      use_vcr_cassette

      specify 'successfull subscription' do
        page.should have_content('Account Settings')

        within '.subscribe-plan.monthly' do
          click_link 'Upgrade'
        end

        page.should have_content('Activecell Monthly')

        fill_in_subscription_form
        click_button 'Subscribe'
        should_create_company_subscription \
          plan_code: 'monthly', plan_name: 'Activecell Monthly',
          plan_interval_unit: 'months', plan_interval_length: 1,
          trial_ends_at: Time.utc(2011, 6, 21, 21, 30, 16)
      end
    end

    describe 'annual subscription' do
      use_vcr_cassette

      specify 'successfull subscription' do
        page.should have_content('Account Settings')

        within '.subscribe-plan.annual' do
          click_link 'Upgrade'
        end

        page.should have_content('Activecell Annual')

        fill_in_subscription_form
        click_button 'Subscribe'

        should_create_company_subscription \
          plan_code: 'annual', plan_name: 'Activecell Annual',
          plan_interval_unit: 'months', plan_interval_length: 12,
          trial_ends_at: Time.utc(2012, 10, 18, 11, 10, 47)
      end
    end

    describe 'advisor subscription' do
      use_vcr_cassette

      specify 'successfull subscription' do
        within '.subscribe-plan.advisor-annual' do
          click_link 'Upgrade'
        end

        page.should have_content('Activecell Advisor Annual')

        fill_in_subscription_form
        click_button 'Subscribe'

        should_create_company_subscription \
          plan_code: 'advisor_annual', plan_name: 'Activecell Advisor Annual',
          plan_interval_unit: 'months', plan_interval_length: 12,
          trial_ends_at: Time.utc(2012, 10, 18, 11, 10, 47)

        # should upgrade company to advisor
        advisor_company = AdvisorCompany.where(id: company.id).first
        expect(advisor_company).to be_present
      end
    end
  end

  context 'with active subscription' do
    let(:plan_name) { 'Activecell Monthly' }
    background do
      attributes = { uuid: subscription_uuid, plan_name: plan_name, plan_unit_amount_in_cents: 4999, plan_interval_unit: 'months' }
      company.subscription = build(:company_subscription, :active, attributes)
      company.save!

      navigate_to('settings', 'account')
      stub_recurly_jsonp_calls(token: '99624fdb4af045eda32aa051dcfcc394')
    end

    describe 'update billing info' do
      use_vcr_cassette

      scenario 'display current plan info' do
        page.should have_content(%Q{Your current plan is "#{plan_name}" $49.99 per month})
      end

      scenario 'fill in the billing form with valid attributes and submit' do
        within '#recurly-edit-subscription-form' do
          page.should have_content('Billing Info')

          within '.billing_info' do
            within '.credit_card' do
              find('.field.first_name input').set('Lukasz')
              find('.field.last_name input').set('Bandzarewicz')
              find('.field.card_number input').set('4111 1111 1111 1111')
              find('.field.cvv input').set('111')
            end

            within '.address' do
              find('.field.address1 input').set('Blich 3/7')
              find('.field.city input').set('Krakow')
              find('.field.zip input').set('30-000')
              find('.field.country select option[value=PL]').select_option
            end
          end

          click_button 'Update'
        end

        current_path.should == root_path
        page.should display_flash_message('Billing information was successfully updated!')
      end
    end

    describe 'upgrade subscription' do
      use_vcr_cassette
      let(:company_subscription) { company.subscription }

      scenario 'click "change to annual" button' do
        page.should have_content('Your current plan is "Activecell Monthly" $49.99 per month')

        expect do
          click_link 'change to annual'
          confirm_dialog

          page.should have_link 'change to monthly'
          company_subscription.reload
        end.to change(company_subscription, :plan_code).from('monthly').to('annual')

        # should update company's subscription
        company_subscription.should be_present
        company_subscription.plan_code.should == 'annual'
        company_subscription.plan_name.should == 'Activecell Annual'
        company_subscription.uuid.should_not be_nil
        company_subscription.uuid.should == subscription_uuid
        company_subscription.state.should == 'active'
        company_subscription.expires_at.should be_nil
      end
    end

    # TODO
    describe 'downgrade subscription'

    describe 'cancel subscription' do
      use_vcr_cassette
      let(:company_subscription) { company.subscription }

      scenario 'click "cancel" button' do
        page.should have_content('You can')
        page.should have_content('cancel')
        page.should have_content('your account at any time.')

        expect do
          click_link 'cancel'
          confirm_dialog('Are you sure you wish to cancel your account? This cannot be undone.')
          should_load_sign_in_page

          company_subscription.reload
        end.to change(company_subscription, :state).from('active').to('expired')

        # should update company's subscription
        company_subscription.should be_present
        company_subscription.plan_code.should == 'annual'
        company_subscription.plan_name.should == 'Activecell Annual'
        company_subscription.uuid.should_not be_nil
        company_subscription.uuid.should == subscription_uuid
        company_subscription.state.should == 'expired'
        company_subscription.expires_at.should_not be_nil
      end
    end
  end

  context 'with cancelled subscription' do
    before do
      company.subscription = build(:company_subscription, :canceled, uuid: subscription_uuid)
      company.save

      navigate_to('settings', 'account')
      stub_recurly_jsonp_calls(token: '99624fdb4af045eda32aa051dcfcc394')
    end

    scenario 'display information about canceled subscription' do
      page.should have_content('Your subscription is cancelled.')
    end
  end

  context 'when the billing is overridden' do
    let!(:advisor_company) { create(:advisor_company) }

    before do
      company.invite_advisor(advisor_company)
      Mongoid.observers.disable(:all) do
        advisor_company.override_billing_for(company)
      end

      visit root_path
      navigate_to('settings')
    end

    scenario 'should not be accessible' do
      within 'ul.sub-nav' do
        page.should have_link('user')
        page.should have_link('company')
        page.should have_link('integrations')
        page.should_not have_link('account')
      end
    end
  end

end
