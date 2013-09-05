require 'spec_helper'

feature 'Advisor settings page', :billing, :advisor, js: true do
  include_context 'advisor settings page'

  let(:subscription_uuid) { 'dummy-subscription-uuid' }
  let(:plan_name) { 'Activecell Monthly' }

  background do
    attributes = { uuid: subscription_uuid, plan_name: plan_name, plan_unit_amount_in_cents: 4999, plan_interval_unit: 'months' }
    advisor_company.subscription = build(:company_subscription, :active, attributes)
    advisor_company.save!

    Mongoid.observers.disable(:all) do
      advisor_company.override_billing_for(second_advised_company)
    end

    login_as(user)
    navigate_to('settings', 'advisor')
  end

  scenario 'displays checkboxes' do
    within_row_for(first_affiliation) do
      find('input[name="override_billing"]').should_not be_checked
    end

    within_row_for(second_affiliation) do
      find('input[name="override_billing"]').should be_checked
    end
  end

  describe 'override billing' do
    def override_billing_for(affiliation)
      within_row_for(affiliation) do
        check 'override_billing'
        wait_until { page.has_no_content?('Saving') rescue true }
      end
      affiliation.reload
    end

    context 'when the company does not have an active subscription' do
      use_vcr_cassette
      background { override_billing_for(first_affiliation) }

      scenario 'update subscription add-ons details' do
        first_affiliation.override_billing.should be_true
      end
    end

    context 'when the company has an active subscription' do
      let(:company_subscription_uuid) { 'company-subscription-uuid' }
      use_vcr_cassette

      background do
        attributes = { uuid: company_subscription_uuid, plan_code: 'monthly', plan_name: plan_name, plan_unit_amount_in_cents: 4999, plan_interval_unit: 'months' }
        third_advised_company.subscription = build(:company_subscription, :active, attributes)
        third_advised_company.save!

        override_billing_for(third_affiliation)
      end

      scenario 'update subscription add-ons details' do
        third_affiliation.override_billing.should be_true
      end

      scenario 'terminate existing subscription' do
        third_advised_company.reload
        third_advised_company.subscriber.should be_nil

        subscription = third_advised_company.subscription
        subscription.state.should == 'expired'
        subscription.terminated_by_advisor.should be_true

        terminated_subscriber = RecurlySubscriber.new(third_advised_company.reload)
        terminated_subscriber.has_active_subscription?.should be_false
      end
    end
  end

  describe 'rollback override billing' do
    def rollback_override_billing_for(affiliation)
      within_row_for(affiliation) do
        uncheck 'override_billing'
        wait_until { page.has_no_content?('Saving') rescue true }
      end
      affiliation.reload
    end

    context 'when a company was on free plan' do
      use_vcr_cassette
      before { rollback_override_billing_for(second_affiliation) }

      scenario 'update subscription add-ons details' do
        second_affiliation.override_billing.should be_false
      end
    end

    context 'when a company was on paid plan' do
      use_vcr_cassette
      before { rollback_override_billing_for(second_affiliation) }

      scenario 'update subscription add-ons details' do
        second_affiliation.override_billing.should be_false
      end
    end
  end

  context 'when the billing is overridden by other advisor' do
    let!(:other_advisor_company) { create(:advisor_company) }
    let!(:third_advised_company) { create(:company) }

    before do
      advisor_company.become_an_advisor_for(third_advised_company)
      other_advisor_company.become_an_advisor_for(third_advised_company)

      Mongoid.observers.disable(:all) do
        other_advisor_company.override_billing_for(third_advised_company)
      end

      navigate_to('settings', 'advisor')
    end

    let(:third_affiliation) { advisor_company_affiliation_for(third_advised_company) }

    scenario 'should display notification about overridden banding' do
      within_row_for(third_affiliation) do
        page.should have_content("This company's billing is already overridden by another advisor.")
      end
    end
  end
end
