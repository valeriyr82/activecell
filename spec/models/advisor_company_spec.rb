require 'spec_helper'

describe AdvisorCompany, :advisor do
  let(:advisor_company) { create(:advisor_company) }

  it { should be_a_kind_of(AdvisorCompany::AdvisorAffiliations) }
  it { should be_a_kind_of(AdvisorCompany::AdvisorBranding) }
  it { should be_a_kind_of(AdvisorCompany::AdvisorBilling) }

  describe '#to_json' do
    it { should respond_to(:to_json) }

    # TODO test other field (with shared examples or sth similar)
    describe 'result' do
      subject { advisor_company.to_json }

      context 'when the company advises some companies' do
        let!(:first_advised_company) { create(:company) }
        let!(:second_advised_company) { create(:company) }

        before do
          advisor_company.become_an_advisor_for(first_advised_company)
          advisor_company.become_an_advisor_for(second_advised_company)
        end

        it { should have_json_path('advised_companies') }
        it { should have_json_size(2).at_path('advised_companies') }
      end
    end
  end

  describe "#subscriber" do
    it { should respond_to(:subscriber) }

    describe 'result' do
      subject { advisor_company.subscriber }
      it { should be_an_instance_of(RecurlyAdvisorSubscriber) }
    end
  end
end
