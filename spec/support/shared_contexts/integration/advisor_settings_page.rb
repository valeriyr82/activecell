shared_context 'advisor settings page' do
  let!(:user) { create(:user, email: 'test@user.com') }
  let!(:advisor_company) { create(:advisor_company, users: [user]) }

  let!(:first_advised_company) { create(:company) }
  let!(:second_advised_company) { create(:company) }
  let!(:third_advised_company) { create(:company) }

  let(:first_affiliation) { advisor_company_affiliation_for(first_advised_company) }
  let(:second_affiliation) { advisor_company_affiliation_for(second_advised_company) }
  let(:third_affiliation) { advisor_company_affiliation_for(third_advised_company) }

  background do
    advisor_company.become_an_advisor_for(first_advised_company)
    advisor_company.become_an_advisor_for(second_advised_company)
    advisor_company.become_an_advisor_for(third_advised_company)
  end

  def advisor_company_affiliation_for(company)
    advisor_company.advised_company_affiliations.where(company_id: company).first
  end

  def within_row_for(affiliation, &block)
    within "tr.affiliation-#{affiliation.id}", &block
  end
end
