require 'spec_helper'

describe Company::AdvisorUpgrade, :advisor do
  let!(:advisor_company) { create(:advisor_company) }
  subject { advisor_company }

  describe '#upgrade_to_advisor!' do
    let!(:company) { create(:company) }

    context 'when the company is advised' do
      before { company.stub(advised?: true) }

      it 'should raise an error' do
        expect do
          company.upgrade_to_advisor!
        end.to raise_error('cannot be updated to advisor since is advised')
      end
    end

    it 'should update the given company to advisor' do
      upgraded_company = company.upgrade_to_advisor!

      upgraded_company.should be_an_instance_of(AdvisorCompany)
      upgraded_company.id.should == company.id
      upgraded_company.should be_persisted

      Company.find(company.id).should be_an_instance_of(AdvisorCompany)
      AdvisorCompany.find(company.id).should == upgraded_company
    end

    context 'when a company was previously an advisor' do
      let!(:advisor_company) { create(:advisor_company) }
      let!(:other_company) { create(:company) }
      before do
        advisor_company.become_an_advisor_for(company)
        advisor_company.become_an_advisor_for(other_company)
        advisor_company.downgrade_from_advisor!
      end

      it 'should restore all dependent affiliations' do
        company = Company.find(advisor_company.id)
        expect do
          company.upgrade_to_advisor!
        end.to change(advisor_company.advised_company_affiliations, :count).by(2)
      end
    end
  end
end
