require 'spec_helper'

describe CompanySubscriptionsController, :billing do
  let(:company) { mock_model(Company, subdomain: 'company-subdomain') }
  let(:subscriber) { mock }

  let(:user) { mock_model(User) }
  before { login_as(user) }

  before do
    controller.stub(:current_company).and_return(company)
    controller.stub(:current_subscriber).and_return(subscriber)
  end

  describe 'on GET to :new' do
    before { get :new }

    it { should respond_with(:success) }
    it { should respond_with_content_type(:json) }
  end

  describe 'on POST to :create' do
    let(:recurly_token) { 'the-token' }
    let(:recurly_subscription) { mock(valid?: true) }

    before do
      subscriber.should_receive(:update_company_subscription_by_token).with(recurly_token).and_return(recurly_subscription)

      subscriber.stub_chain(:subscription, :plan_code).and_return('advisor_annual')
      company.should_receive(:upgrade_to_advisor!).and_return(true)

      post :create, recurly_token: recurly_token
    end

    it { should set_the_flash }
    it { should redirect_to(app_url(subdomain: company.subdomain)) }
  end

  describe 'on GET to :edit' do
    let(:subscriber) { mock }

    before do
      subscriber.should_receive(:account_code).and_return(':account_code')
      get :edit
    end

    it { should respond_with(:success) }
    it { should respond_with_content_type(:json) }
  end

  describe 'on PUT to :cancel' do
    before do
      subscriber.should_receive(:cancel_subscription).and_return(true)
      put :cancel
    end

    it { should respond_with(:success) }
    it { should respond_with_content_type(:json) }
  end

end
