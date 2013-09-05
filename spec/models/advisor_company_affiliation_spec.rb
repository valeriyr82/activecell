require 'spec_helper'

describe AdvisorCompanyAffiliation, :advisor, :branding, :billing do
  let(:affiliation) { create(:company_advisor_affiliation) }
  subject { affiliation }
  let(:advisor_company) { affiliation.advisor_company }
  let(:company) { affiliation.company }

  it { should be_paranoid_document }

  describe 'fields' do
    it { should have_field(:override_branding).of_type(Boolean).with_default_value_of(false) }
    it { should have_field(:override_billing).of_type(Boolean).with_default_value_of(false) }
  end

  describe 'indexes' do
    it { should have_index_for({ company_id: 1, advisor_company_id: 1 }).with_options(unique: true) }
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:advisor_company).of_type(Company).as_inverse_of(:advisor_company_affiliations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:advisor_company) }
    it { should validate_uniqueness_of(:advisor_company).scoped_to(:company_id) }
  end

  describe 'callbacks' do
    describe '#after_update' do
      context 'when a branding was overridden and access is being revoked' do
        let!(:affiliation) { create(:company_advisor_affiliation, :branding_overridden) }

        it 'should rollback the branding' do
          expect do
            affiliation.update_attribute(:has_access, false)
          end.to change(affiliation, :override_branding).from(true).to(false)
        end
      end
    end

    describe '#before_destroy' do
      context 'when the billing is overridden' do
        let!(:affiliation) { create(:company_advisor_affiliation, :billing_overridden) }
        let(:company) { affiliation.company }
        let(:advisor_company) { affiliation.advisor_company }

        before { advisor_company.subscriber.should_receive(:remove_advised_company).with(company) }

        it 'should notify remove advised company add-on' do
          Mongoid.observers.enable(:all) do
            affiliation.destroy
          end
        end
      end
    end

    describe '#after_destroy' do
      context 'when the branding is overridden' do
        let!(:affiliation) { create(:company_advisor_affiliation, :branding_overridden) }

        it 'should rollback branding' do
          expect do
            affiliation.destroy
          end.to change(affiliation, :override_branding).from(true).to(false)

          deleted_affiliation = AdvisorCompanyAffiliation.deleted.last
          deleted_affiliation.should be_present
          deleted_affiliation.override_branding.should be_false
        end
      end

      context 'when the billing is overridden' do
        let!(:affiliation) { create(:company_advisor_affiliation, :billing_overridden) }

        it 'should rollback billing' do
          expect do
            affiliation.destroy
          end.to change(affiliation, :override_billing).from(true).to(false)

          deleted_affiliation = AdvisorCompanyAffiliation.deleted.last
          deleted_affiliation.override_billing.should be_false
        end
      end
    end
  end

  describe '#to_json' do
    it { should respond_to(:to_json) }

    let!(:affiliation) { create(:company_advisor_affiliation, :branding_overridden, :billing_overridden) }
    let(:company) { affiliation.company }
    let(:advisor_company) { affiliation.advisor_company }

    describe 'result' do
      subject { affiliation.to_json }

      it { should have_json_path('id') }

      it 'should include #has_access field' do
        should have_json_path('has_access')
        should have_json_value(true).at_path('has_access')
      end

      it 'should include #override_branding field' do
        should have_json_path('override_branding')
        should have_json_value(true).at_path('override_branding')
      end

      it 'should include #can_override_branding field' do
        should have_json_path('can_override_branding')
        should have_json_value(true).at_path('can_override_branding')
      end

      it 'should include #override_billing field' do
        should have_json_path('override_billing')
        should have_json_value(true).at_path('override_billing')
      end

      it 'should include #can_override_billing field' do
        should have_json_path('can_override_billing')
        should have_json_value(true).at_path('can_override_billing')
      end

      it 'should contain affiliation type field' do
        should have_json_path('_type')
        should have_json_value('AdvisorCompanyAffiliation').at_path('_type')
      end

      it 'should include company basic data' do
        should have_json_path('company/id')
        should have_json_value(company.id.to_s).at_path('company/id')

        should have_json_path('company/name')
        should have_json_value(company.name).at_path('company/name')

        should have_json_path('company/subdomain')
        should have_json_value(company.subdomain).at_path('company/subdomain')
      end

      it 'should include advisor company basic data' do
        should have_json_path('advisor_company/id')
        should have_json_value(advisor_company.id.to_s).at_path('advisor_company/id')

        should have_json_path('advisor_company/name')
        should have_json_value(advisor_company.name).at_path('advisor_company/name')
      end
    end
  end

  describe "#can_override_branding?" do
    before do
      advisor_company.should_receive(:can_override_branding_for?).
          with(company).and_return(true)
    end

    specify { affiliation.can_override_branding?.should be_true }
  end

  describe "#can_override_billing?" do
    before do
      advisor_company.should_receive(:can_override_billing_for?).
          with(company).and_return(true)
    end

    specify { affiliation.can_override_billing?.should be_true }
  end

end
