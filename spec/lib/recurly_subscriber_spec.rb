require 'spec_helper'

describe RecurlySubscriber, :billing do
  before { time_travel_to(1.month.ago) }
  after { back_to_the_present }

  let!(:company) { create(:company, _id: 'company-id') }

  let(:subscriber) { described_class.new(company) }
  subject { subscriber }

  its(:company) { should == company }
  its(:company_subscription) { should == company.subscription }

  def account_attributes(attributes)
    attributes.reverse_merge \
        account_code: 'test-account-code',
        email: 'user@example.com',
        first_name: 'Admin',
        last_name: 'Adminowski',
        billing_info: {
            number: '4111-1111-1111-1111',
            month: 1,
            year: 2014,
        }
  end

  shared_context 'with active subscription' do |account_attributes, plan_code = 'annual'|
    let(:account) { account_attributes(account_attributes) }
    let(:subscription_uuid) { subscriber.subscription.uuid }

    before { subscriber.subscribe_to_plan(plan_code, account) }
  end

  shared_context 'not found subscription' do
    let(:subscription_uuid) { 'not-existing-subscription-uuid' }
    before do
      company.subscription = build(:company_subscription, :active, uuid: subscription_uuid)
      company.save!
    end
  end

  def should_raise_recurly_resource_not_found_error(&block)
    expect { block.call }.to raise_error { |error| error.should be_an_instance_of(Recurly::Resource::NotFound) }
  end

  describe '#account_code' do
    it { should respond_to(:account_code) }

    describe 'result' do
      subject { subscriber.account_code }

      it 'should include company id' do
        should include(company._id)
      end

      it 'should return unique recurly account code' do
        should == "#{company._id}@recurly"
      end
    end
  end

  describe '#subscription' do
    it { should respond_to(:subscription) }

    context 'when the subscription cannot be found' do
      use_vcr_cassette
      include_context 'not found subscription'

      specify do
        should_raise_recurly_resource_not_found_error { subscriber.subscription }
      end
    end

    describe 'result' do
      let(:result) { subscriber.subscription }
      subject { result }

      context 'without subscription' do
        it { should be_nil }
      end

      context 'with subscription' do
        use_vcr_cassette
        include_context 'with active subscription', account_code: 'test-account-code'

        it { should_not be_nil }
        it { should be_an_instance_of(Recurly::Subscription) }
        its(:uuid) { should == subscription_uuid }
        its(:state) { should == 'active' }
      end
    end
  end

  describe '#subscribe_to_plan' do
    use_vcr_cassette

    let(:account) { account_attributes(account_code: 'new-account-code') }
    let!(:subscription) { subscriber.subscribe_to_plan('annual', account) }

    describe 'persisted company subscription' do
      subject { company.subscription }

      it { should_not be_nil }
      its(:uuid) { should be_present }
      its(:state) { should == 'active' }
      its(:trial_ends_at) { should be_present }
      its(:created_at) { should be_present }
      its(:expires_at) { should be_nil }

      its(:plan_code) { should == 'annual' }
      its(:plan_name) { should == 'Activecell Annual' }
      its(:plan_interval_length) { should == 12 }
      its(:plan_interval_unit) { should == 'months' }
    end

    describe 'created subscription' do
      subject { subscription }

      it do
        should_not be_nil
        should be_an_instance_of(Recurly::Subscription)
      end
    end

    specify 'subscription still should be active' do
      subscriber.has_active_subscription?.should be_true
    end
  end

  describe '#update_company_subscription_by_token' do
    let(:token) { 'some token' }
    let(:subscription) { mock }

    before do
      Recurly.js.should_receive(:fetch).with(token).and_return(subscription)
      subscriber.should_receive(:update_company_subscription_details).with(subscription)
    end

    it 'should find and store a subscription' do
      subscriber.update_company_subscription_by_token(token).should == subscription
    end
  end

  describe '#change_plan_to' do
    it { should respond_to(:change_plan_to) }

    context 'when the subscription is on monthly plan' do
      use_vcr_cassette
      include_context 'with active subscription', { account_code: 'account-with-monthly-plan' }, 'monthly'

      it 'should change plan to annual' do
        expect do
          subscriber.change_plan_to(:annual)
        end.to change(company.subscription, :plan_code).from('monthly').to('annual')
      end
    end

    context 'when the subscription is on annual plan' do
      use_vcr_cassette
      include_context 'with active subscription', { account_code: 'account-with-annual-plan' }, 'annual'

      it 'should change plan to annual' do
        expect do
          subscriber.change_plan_to(:monthly)
        end.to change(company.subscription, :plan_code).from('annual').to('monthly')
      end
    end
  end

  describe '#cancel_subscription' do
    it { should respond_to(:cancel_subscription) }

    context 'when the subscription cannot be found' do
      use_vcr_cassette
      include_context 'not found subscription'

      specify do
        should_raise_recurly_resource_not_found_error { subscriber.cancel_subscription }
      end
    end

    context 'when the subscription can be found' do
      use_vcr_cassette
      include_context 'with active subscription', account_code: 'account-to-cancel-code'
      let!(:cancelled) { subscriber.cancel_subscription }

      it('should return true') { cancelled.should be_true }

      describe 'updated company subscription' do
        subject { company.subscription }

        its(:state) { should == 'canceled' }
        its(:terminated_by_advisor) { should be_false }
      end

      specify 'subscription still should be active' do
        subscriber.has_active_subscription?.should be_true
      end

      specify 'subscription should not be active after one month' do
        time_travel_to(1.month.from_now) do
          subscriber.has_active_subscription?.should be_false
        end
      end
    end
  end

  describe '#terminate_subscription' do
    it { should respond_to(:terminate_subscription) }

    context 'when the subscription cannot be found' do
      use_vcr_cassette
      include_context 'not found subscription'

      specify do
        should_raise_recurly_resource_not_found_error { subscriber.terminate_subscription }
      end
    end

    context 'when the subscription can be found' do
      use_vcr_cassette
      include_context 'with active subscription', account_code: 'account-to-terminate-code'
      let!(:terminated) { subscriber.terminate_subscription }

      it('should return true') { terminated.should be_true }

      describe 'updated company subscription' do
        subject { company.subscription }

        its(:state) { should == 'expired' }
        its(:terminated_by_advisor) { should be_false }
      end

      specify 'subscription should not be active' do
        subscriber.has_active_subscription?.should be_false
      end
    end
  end

  describe '#has_active_subscription?' do
    it { should respond_to(:has_active_subscription?) }

    describe 'result' do
      let(:company_subscription) { mock }
      before { company.stub(subscription: company_subscription) }

      let(:result) { subscriber.has_active_subscription? }
      subject { result }

      context 'when the company has a subscription' do
        before do
          company_subscription.should_receive(:expires_at).at_least(:once).and_return(expiry_date)
        end

        context 'and the subscription is not expired' do
          let(:expiry_date) { nil }
          it { should be_true }
        end

        context 'and the subscription will be expired in the future' do
          let(:expiry_date) { 1.month.from_now }
          it { should be_true }
        end

        context 'and the subscription is expired' do
          let(:expiry_date) { 1.day.ago }
          it { should be_false }
        end
      end

      context 'when the company does not have a subscription' do
        let(:company_subscription) { nil }
        it { should be_false }
      end
    end
  end

  describe '#subscription_is_cancelled?' do
    it { should respond_to(:subscription_is_cancelled?) }

    describe 'result' do
      let(:company_subscription) { mock }
      before do
        company.stub(subscription: company_subscription)
        subscriber.should_receive(:has_active_subscription?).and_return(has_subscription)
      end

      let(:result) { subscriber.subscription_is_cancelled? }
      subject { result }

      context 'when active subscription is present' do
        let(:has_subscription) { true }
        before { company_subscription.should_receive(:state).and_return(state) }

        context 'when the subscription is cancelled' do
          let(:state) { 'canceled' }
          it { should be_true }
        end

        context 'when the subscription is not cancelled' do
          let(:state) { 'active' }
          it { should be_false }
        end
      end

      context 'without subscription' do
        let(:has_subscription) { false }
        it { should be_false }
      end
    end
  end

  describe '#in_trial?' do
    it { should respond_to(:in_trial?) }

    describe 'result' do
      subject { subscriber.in_trial? }

      context 'when it has paid account' do
        before { subscriber.stub(has_active_subscription?: true) }
        it { should be_false }
      end

      context 'when it does not have paid account' do
        before { subscriber.stub(has_active_subscription?: false) }
        it { should be_true }
      end

      context 'when the billing is overridden' do
        before { company.stub(billing_overridden?: true) }
        it { should be_false }
      end

      context 'when the billing is not overridden' do
        before { company.stub(billing_overridden?: false) }
        it { should be_true }
      end
    end
  end

  describe '#trial_days_left' do
    it { should respond_to(:trial_days_left) }

    describe 'result' do
      before { company.stub(:created_at).and_return(created_at) }
      subject { subscriber.trial_days_left }

      context 'when the company was just created' do
        let(:created_at) { Time.now }
        it { should == 30 }
      end

      context 'when the company was created 15 days ago' do
        let(:created_at) { 15.days.ago }
        it { should == 15 }
      end

      context 'when the company was created 30 days ago' do
        let(:created_at) { 30.days.ago }
        it { should == 0 }
      end

      context 'when the company was created 31 days ago' do
        let(:created_at) { 31.days.ago }
        it { should == -1 }
      end

      context 'when the company was created 90 days ago' do
        let(:created_at) { 90.days.ago }
        it { should == -60 }
      end
    end
  end

  describe '#trial_expired?' do
    it { should respond_to(:trial_expired?) }

    describe 'result' do
      let(:created_at) { Time.now }
      before { company.stub(:created_at).and_return(created_at) }

      subject { subscriber.trial_expired? }

      context 'when it is in trial' do
        before { subscriber.stub(in_trial?: true) }

        context 'when the company was just created' do
          let(:created_at) { Time.now }
          it { should be_false }
        end

        context 'when the company was created 15 days ago' do
          let(:created_at) { 15.days.ago }
          it { should be_false }
        end

        context 'when the company was created 30 days ago' do
          let(:created_at) { 30.days.ago }
          it { should be_false }
        end

        context 'when the company was created 31 days ago' do
          let(:created_at) { 31.days.ago }
          it { should be_true }
        end

        context 'when the company was created 90 days ago' do
          let(:created_at) { 90.days.ago }
          it { should be_true }
        end
      end

      context 'when it is not in trial' do
        before { subscriber.stub(in_trial?: false) }
        it { should be_false }
      end
    end
  end

  describe '#as_json' do
    it { should respond_to(:as_json) }

    describe 'result' do
      before do
        subscriber.should_receive(:has_active_subscription?).and_return(true)
        subscriber.should_receive(:subscription_is_cancelled?).and_return(false)
      end

      subject { subscriber.as_json }

      it { should be_an_instance_of(Hash) }
      it { should include(:account_code) }

      it { should include(:has_active_subscription?) }
      its([:has_active_subscription?]) { should be_true }

      it { should include(:subscription_is_cancelled?) }
      its([:subscription_is_cancelled?]) { should be_false }

      it { should include(:subscription) }
    end
  end
end
