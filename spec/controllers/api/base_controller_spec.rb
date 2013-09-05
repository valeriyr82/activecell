require 'spec_helper'

describe Api::BaseController, :api do
  describe "#auth!" do
    controller(Api::BaseController) do
      def index
        render nothing: true
      end
    end

    before do
      controller.stub(:current_user).and_return(user)
      controller.stub(:check_trial_period!).and_return(true)
      controller.should_receive(:basic_http_auth!).and_return(authenticated_with_basic_http_auth) if user.nil?

      get :index, format: :json
    end

    context 'when an user is logged' do
      let(:user) { mock_model(User) }
      it { should respond_with(:success) }
    end

    context 'when an user is not logged' do
      let(:user) { nil }

      context 'when the request is authenticated with basic http auth' do
        let(:authenticated_with_basic_http_auth) { true }
        it { should respond_with(:success) }
      end

      context 'when basic http authentication fails' do
        let(:authenticated_with_basic_http_auth) { false }
        it { should respond_with(:forbidden) }
      end
    end
  end

  describe '#check_trial_period!' do
    controller(Api::BaseController) do
      def index
        render nothing: true
      end
    end

    let(:company) { mock }

    before do
      controller.stub(:auth!).and_return(true)
      #controller.stub(:current_company).and_return(company)
      CurrentCompanyResolver.stub_chain(:new, :resolve).and_return(company)
      company.should_receive(:trial_expired?).and_return(expired)

      get :index, format: :json
    end

    context 'when the trial expired' do
      let(:expired) { true }
      it { should respond_with(:payment_required) }
    end

    context 'when the trial did not expire' do
      let(:expired) { false }
      it { should respond_with(:success) }
    end
  end

  describe 'on Mongoid::Errors::DocumentNotFound error' do
    controller(Api::BaseController) do
      def index
        raise Mongoid::Errors::DocumentNotFound.new(User, {})
      end
    end

    let(:user) { mock_model(User) }

    before do
      controller.stub(:check_trial_period!).and_return(true)
      controller.stub(:current_user).and_return(user)

      get :index, format: :json
    end

    it { should respond_with(:not_found) }
    it { should respond_with_content_type(:json) }
  end
end
