require 'spec_helper'

describe CompanyObserver, :billing do
  subject(:observer) { described_class.instance }
  let(:company) { mock_model(Company) }

  describe '#before_destroy' do
    it { should respond_to(:before_destroy) }

    let(:subscriber) { mock }

    it 'should terminate recurly subscription' do
      company.should_receive(:subscriber).and_return(subscriber)
      subscriber.should_receive(:terminate_subscription)

      observer.before_destroy(company)
    end
  end
end
