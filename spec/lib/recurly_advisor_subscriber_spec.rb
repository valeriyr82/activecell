require 'spec_helper'

describe RecurlyAdvisorSubscriber, :billing do
  use_vcr_cassette

  let(:company) { create(:company, _id: 'company-id') }
  let(:advisor_company) { create(:advisor_company, _id: 'advisor-company-id') }

  let(:advisor_subscriber) { described_class.new(advisor_company) }
  subject { advisor_subscriber }

  def account_attributes(attributes)
    attributes.reverse_merge \
        email: 'user@example.com',
        first_name: 'Admin',
        last_name: 'Adminowski',
        billing_info: {
            number: '4111-1111-1111-1111',
            month: 1,
            year: 2014,
        }
  end

  before do
    attributes = account_attributes(account_code: "#{advisor_company.id}@recurly")
    advisor_subscriber.subscribe_to_plan('annual', attributes)
  end

  describe '#add_advised_company' do
    it { should respond_to(:add_advised_company) }

    context 'when the advised company does not have an active subscription' do
      use_vcr_cassette

      it 'should increment add-on quantity' do
        advisor_subscriber.add_advised_company(company)

        company.subscription.should be_nil
        company.subscriber.has_active_subscription?.should be_false

        advisor_company.subscription.should_not be_nil
        advisor_company.subscriber.has_active_subscription?.should be_true
      end
    end

    context 'when the advised company has an active subscription' do
      use_vcr_cassette

      before do
        attributes = account_attributes(account_code: "#{company.id}@recurly")
        company.subscriber.subscribe_to_plan('annual', attributes)
      end

      before { advisor_subscriber.add_advised_company(company) }

      it 'should increment add-on quantity' do
        advisor_company.subscription.should_not be_nil
        advisor_company.subscriber.has_active_subscription?.should be_true
      end

      it 'should terminate company subscription' do
        company.subscription.should_not be_nil
        company.subscription.terminated_by_advisor.should be_true
        company.subscriber.has_active_subscription?.should be_false
      end
    end
  end

  describe '#remove_advised_company' do
    context 'when the company had an active subscription before' do
      use_vcr_cassette

      before do
        attributes = account_attributes(account_code: "#{company.id}@recurly")
        company.subscriber.subscribe_to_plan('annual', attributes)
        advisor_subscriber.add_advised_company(company)
      end

      it 'should renew the subscription' do
        advisor_subscriber.remove_advised_company(company)

        company.subscription.terminated_by_advisor.should be_false
        company.subscriber.has_active_subscription?.should be_true
      end
    end

    context 'when the advisor has only one advised company' do
      use_vcr_cassette
      before { advisor_subscriber.add_advised_company(company) }

      it 'should remove advised companies add-on from the subscription' do
        advisor_subscriber.remove_advised_company(company)

        company.subscription.should be_nil
        company.subscriber.subscription_was_terminated_by_advisor?.should be_false
        company.subscriber.has_active_subscription?.should be_false
      end
    end

    context 'when the advisor has more that one advised companies' do
      use_vcr_cassette

      let!(:other_company) { create(:company) }
      before do
        advisor_subscriber.add_advised_company(company)
        advisor_subscriber.add_advised_company(other_company)
      end

      it 'should decrement add-ons quantity' do
        advisor_subscriber.remove_advised_company(company)
      end
    end
  end

  describe "#advised_company_add_ons_quantity" do
    let(:subscription_uuid) { nil }
    before { advisor_company.subscription.stub(:uuid).and_return(subscription_uuid) }

    it { should respond_to(:advised_company_add_ons_quantity) }

    describe 'result' do
      let(:advisor_subscriber) { RecurlyAdvisorSubscriber.new(advisor_company) }
      subject { advisor_subscriber.advised_company_add_ons_quantity }

      context 'when the subscription is not active' do
        before { advisor_subscriber.stub(has_active_subscription?: false) }
        it { should == 0 }
      end

      context 'when the subscription is active' do
        let(:recurly_subscription) {  Recurly::Subscription.find(subscription_uuid) }

        before { advisor_subscriber.stub(has_active_subscription?: true) }

        context 'when an advisor does not override billings' do
          use_vcr_cassette

          let(:subscription_uuid) { 'without-add-ons' }
          before { advisor_subscriber.stub(subscription: recurly_subscription) }

          it { should == 0 }
        end

        context 'when an advisor overrides billing for some companies' do
          use_vcr_cassette

          let(:subscription_uuid) { 'with-add-ons' }
          before { advisor_subscriber.stub(subscription: recurly_subscription) }

          it { should > 0 }
          it { should == 2 }
        end
      end
    end
  end
end
