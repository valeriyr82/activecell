require 'spec_helper'

describe Company::Billing, :billing do
  let!(:company) { create(:company) }
  subject { company }

  describe 'associations' do
    it { should embed_one(:subscription).of_type(CompanySubscription) }
  end

  describe '#subscriber' do
    it { should respond_to(:subscriber) }

    describe 'result' do
      subject { company.subscriber }

      context 'when the billing is not overridden' do
        before { company.stub(billing_overridden?: false) }
        it { should be_an_instance_of(RecurlySubscriber) }
      end

      context 'when the billing is overridden' do
        before { company.stub(billing_overridden?: true) }
        it { should be_nil }
      end
    end
  end

  describe '#billing_overridden?' do
    it { should respond_to(:billing_overridden?) }

    describe 'result' do
      subject { company.billing_overridden? }

      context 'when a company does not have any advisors' do
        it { should be_false }
      end

      context 'when a company has an advisor' do
        let!(:advisor_company) { create(:advisor_company) }
        before { company.invite_advisor(advisor_company) }

        context 'when the billing is overridden' do
          let(:affiliation) do
            company.advisor_company_affiliations.with_access.where(advisor_company_id: advisor_company.id).first
          end

          before do
            Mongoid.observers.disable(:all) do
              affiliation.update_attribute(:override_billing, true)
            end
          end

          it { should be_true }

          context 'but an access was revoked' do
            before { affiliation.update_attribute(:has_access, false) }
            it { should be_false }
          end
        end

        context 'when the billing is not overridden' do
          it { should be_false }
        end
      end
    end
  end

end
