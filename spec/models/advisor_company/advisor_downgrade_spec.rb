require 'spec_helper'

describe AdvisorCompany::AdvisorDowngrade, :advisor do
  let!(:advisor_company) { create(:advisor_company) }
  subject { advisor_company }

  describe '#downgrade_from_advisor!' do
    it 'should downgrade the given company to advisor' do
      downgraded_company = advisor_company.downgrade_from_advisor!

      downgraded_company.should be_an_instance_of(Company)
      downgraded_company.id.should == downgraded_company.id
      downgraded_company.should be_persisted

      Company.find(downgraded_company.id).should be_an_instance_of(Company)
      expect do
        AdvisorCompany.find(downgraded_company.id)
      end.to raise_error(Mongoid::Errors::DocumentNotFound)
    end

    context 'with several advised companies' do
      let!(:first_company) { create(:company) }
      let!(:second_company) { create(:company) }

      before do
        advisor_company.become_an_advisor_for(first_company)
        advisor_company.become_an_advisor_for(second_company)
      end

      it 'should delete dependent affiliations' do
        expect do
          advisor_company.downgrade_from_advisor!
        end.to change(advisor_company.advised_company_affiliations, :count).by(-2)
      end

      specify 'other companies #advisor_companies should not include this advisor' do
        advisor_company.downgrade_from_advisor!

        first_company.advisor_companies.should_not include(advisor_company)
        second_company.advisor_companies.should_not include(advisor_company)
      end
    end
  end
end
