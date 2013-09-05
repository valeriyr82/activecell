require 'spec_helper'

describe CompanyAffiliation, :advisor do

  describe 'fields' do
    it { should have_field(:has_access).of_type(Boolean).with_default_value_of(true) }
  end

  describe 'associations' do
    it { should belong_to(:company).as_inverse_of(:advisor_company_affiliations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:company) }
  end

  describe 'scopes' do
    let!(:company) { create(:company) }
    let!(:affiliation_1) { create(:company_affiliation, company: company) }
    let!(:affiliation_2) { create(:company_affiliation, :without_access, company: company) }

    describe '.with_access' do
      it 'should return affiliations with granted access' do
        with_access = CompanyAffiliation.with_access
        with_access.should have(1).item
        with_access.should include(affiliation_1)
        with_access.should_not include(affiliation_2)
      end
    end
  end

end
