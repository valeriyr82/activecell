require 'spec_helper'

describe ApplicationController do
  let(:user)    { mock_model(User) }
  let(:company) { mock_model(Company, users: [user]) }

  describe "#current_company" do
    let(:resolver) { mock }

    before do
      resolver.should_receive(:resolve).once.and_return(company)
      controller.should_receive(:current_company_resolver).once.and_return(resolver)
    end

    it 'returns current company' do
      controller.send(:current_company).should == company
    end

    it 'memorizes the result' do
      controller.send(:current_company)
      controller.send(:current_company).should == company
    end
  end

  describe '#current_subscriber' do
    before { controller.stub(:current_company).and_return(current_company) }

    context 'when the current company is present' do
      let(:current_company) { mock }
      let(:subscriber) { mock }

      before { current_company.should_receive(:subscriber).and_return(subscriber) }

      it 'returns a subscriber' do
        subscriber = controller.send(:current_subscriber)

        subscriber.should_not be_nil
        subscriber.should == subscriber
      end
    end

    context 'when the current company is not present' do
      let(:current_company) { nil }

      it 'returns nil ' do
        controller.send(:current_subscriber).should be_nil
      end
    end
  end

end
