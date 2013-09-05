require 'spec_helper'

describe AdvisorCompany::AdvisorBranding, :advisor, :branding do
  let!(:advisor_company) { create(:advisor_company) }
  subject { advisor_company }

  describe '#can_override_branding_for?' do
    it { should respond_to(:can_override_branding_for?) }

    describe 'the result' do
      let!(:company) { create(:company) }
      let!(:other_advisor_company) { create(:advisor_company) }

      let(:result) { advisor_company.can_override_branding_for?(company) }
      subject { result }

      context 'when the given company belongs to only one advisor' do
        before { company.invite_advisor(advisor_company) }
        it { should be_true }
      end

      context 'when the given company has more than one advisors' do
        before do
          company.invite_advisor(advisor_company)
          company.invite_advisor(other_advisor_company)
        end

        context 'when a branding for the given company is not overridden' do
          specify 'all advisors can override' do
            should be_true
            other_advisor_company.can_override_branding_for?(company).should be_true
          end
        end

        context 'when the other advisor already overrides the branding' do
          let(:affiliation) { other_advisor_company.advised_company_affiliations.where(company_id: company.id).first }
          before { affiliation.update_attribute(:override_branding, true) }

          it { should be_false }

          context 'when other advisor downgrades his account' do
            before { other_advisor_company.downgrade_from_advisor! }
            it { should be_true }
          end

          context 'when an access for the other advisor was revoked' do
            before { affiliation.update_attribute(:has_access, false) }
            it { should be_true }
          end
        end
      end
    end
  end

  describe '#override_branding_for' do
    let!(:advisor_company) { create(:advisor_company) }
    let!(:company) { create(:company) }
    let!(:other_company) { create(:company) }
    let(:affiliation) { advisor_company.advised_company_affiliations.where(company_id: company.id).first }

    before do
      advisor_company.become_an_advisor_for(company)
      advisor_company.become_an_advisor_for(other_company)

      advisor_company.should_receive(:can_override_branding_for?).with(company).
          and_return(can_override)
    end

    context 'when the branding can be overridden' do
      let(:can_override) { true }

      it 'should return true' do
        advisor_company.override_branding_for(company).should be_true
      end

      it 'should set #override_branding on the affiliation' do
        expect do
          advisor_company.override_branding_for(company)
          affiliation.reload
        end.to change(affiliation, :override_branding).from(false).to(true)
      end
    end

    context 'otherwise' do
      let(:can_override) { false }

      it 'should return false' do
        advisor_company.override_branding_for(company).should be_false
      end

      it 'should not set #override_branding on the affiliation' do
        expect do
          advisor_company.override_branding_for(company)
          affiliation.reload
        end.to_not change(affiliation.reload, :override_branding).to(true)
      end
    end
  end

end
