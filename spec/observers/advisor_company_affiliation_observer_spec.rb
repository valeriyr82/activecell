require 'spec_helper'

describe AdvisorCompanyAffiliationObserver, :billing do
  subject(:observer) { described_class.instance }
  let(:affiliation) { mock_model(AdvisorCompanyAffiliation) }
  let(:company) { mock_model(Company) }
  let(:subscriber) { mock }

  before do
    affiliation.stub(:company).and_return(company)
    affiliation.stub_chain(:advisor_company, :subscriber).and_return(subscriber)
  end

  describe '#before_update' do
    it { should respond_to(:before_update) }

    before { affiliation.stub(override_billing_changed?: true) }

    context 'when #override_billing changed to true' do
      before do
        affiliation.should_receive(:override_billing?).and_return(true)
        subscriber.should_receive(:add_advised_company).with(company)
      end

      it 'should increment advised company add-ons quantity' do
        observer.before_update(affiliation)
      end
    end

    context 'when #override_billing changed to false' do
      before do
        affiliation.should_receive(:override_billing?).and_return(false)
        subscriber.should_receive(:remove_advised_company)
      end

      it 'should decrement advised company add-ons quantity' do
        observer.before_update(affiliation)
      end
    end
  end
end
