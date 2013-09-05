require 'spec_helper'

describe AdvisorCompany::AdvisorAffiliations, :advisor do
  let!(:advisor_company) { create(:advisor_company) }
  subject { advisor_company }

  describe 'associations' do
    let!(:first_company) { create(:company) }
    let!(:other_company) { create(:company) }

    describe '#advised_company_affiliations' do
      it do
        should have_many(:advised_company_affiliations).
                   of_type(AdvisorCompanyAffiliation).as_inverse_of(:advisor_company)
      end

      describe 'after #destroy' do
        before do
          advisor_company.become_an_advisor_for(first_company)
          advisor_company.become_an_advisor_for(other_company)

          expect do
            advisor_company.destroy
          end.to change(advisor_company.advised_company_affiliations, :count).by(-2)
        end

        it 'should remove obsolete affiliations' do
          affiliations = advisor_company.advised_company_affiliations.where(company: first_company)
          affiliations.should be_empty
        end

        specify 'other companies #advisor_companies should not include this advisor' do
          first_company.advisor_companies.should_not include(advisor_company)
          other_company.advisor_companies.should_not include(advisor_company)
        end
      end

      describe 'returned list' do
        let(:result) { advisor_company.advised_company_affiliations }
        subject { result }

        context 'when the company is not advising any other company' do
          it { should be_empty }
        end

        context 'when the company advises other company' do
          before { advisor_company.become_an_advisor_for(first_company) }

          it { should have(1).item }

          it 'should include an advised company affiliation' do
            result.first.company.should == first_company
            result.first.advisor_company.should == advisor_company
          end
        end
      end
    end
  end

  describe '#become_an_advisor_for' do
    it { should respond_to(:become_an_advisor_for) }

    let!(:company) { create(:company) }
    it 'should add a company to advised companies' do
      advisor_company.become_an_advisor_for(company)
      advisor_company.reload

      affiliations = advisor_company.advised_company_affiliations
      affiliations.should have(1).item

      affiliation = affiliations.first
      affiliation.company.should == company
      affiliation.advisor_company.should == advisor_company
      affiliation.has_access.should be_true
    end
  end

  describe '#advised_companies' do
    it { should respond_to(:advised_companies) }

    describe 'result' do
      subject { advisor_company.advised_companies }

      context 'when the company is not advising any other companies' do
        it { should be_empty }
      end

      context 'when the company advises several other companies' do
        let!(:first_company) { create(:company) }
        let!(:second_company) { create(:company) }

        before do
          advisor_company.become_an_advisor_for(first_company)
          advisor_company.become_an_advisor_for(second_company)
        end

        it { should have(2).items }
        it 'should include all advised companies' do
          should include(first_company)
          should include(second_company)
        end

        context 'when an access was revoked' do
          before do
            affiliation = advisor_company.advised_company_affiliations.where(company: second_company).first
            affiliation.update_attribute(:has_access, false)
          end

          it { should have(1).items }
          it('should include advised company') { should include(first_company) }
          it('should not include advised company with revoked access') { should_not include(second_company) }
        end
      end
    end
  end

end
