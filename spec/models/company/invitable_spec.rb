require 'spec_helper'

describe Company::Invitable do
  let!(:company) { create(:company) }
  subject { company }

  let!(:advisor_company) { create(:advisor_company) }
  let!(:other_company) { create(:company) }

  describe 'associations' do
    describe '#invitations' do
      it { should have_many(:invitations).as_inverse_of(:company) }

      describe 'after #destroy' do
        before { 2.times { create(:company_invitation, company: company) } }

        it 'should destroy dependent invitations' do
          expect do
            company.destroy
          end.to change(company.reload.invitations, :count).by(-2)
        end
      end
    end
  end

  describe '#invite_user_by_email' do
    let(:user) { mock_model(User) }

    before do
      User.should_receive(:find_by_email).with('foo@bar.com').and_return(user)
      company.should_receive(:invite_user).with(user)
    end

    it 'should add an user to the company' do
      company.invite_user_by_email('foo@bar.com')
    end
  end

  describe '#invite_user' do
    let!(:user) { create(:user) }
    before { company.invite_user(user) }

    it 'should add an user to the company' do
      company.user_affiliations.should have(1).item

      affiliation = company.user_affiliations.first
      affiliation.company.should == company
      affiliation.user.should == user
      affiliation.should have_access
    end

    context 'when an user is already in the company' do
      it 'should return invalid affiliation object' do
        expect do
          affiliation = company.invite_user(user)
          affiliation.should_not be_valid
        end.not_to change(company.reload.user_affiliations, :count)
      end
    end
  end

  describe '#invite_advisor' do
    it 'should not produce obsolete affiliations' do
      company.invite_advisor(advisor_company)

      company.advisor_company_affiliations.should have(1).item

      advisor_company.advisor_company_affiliations.should be_empty
      advisor_company.advised_company_affiliations.should have(1).item
    end

    it 'should add a company as an advisor' do
      expect do
        company.invite_advisor(advisor_company)
      end.to change(company.advisor_company_affiliations, :count).by(1)

      company.advisor_company_affiliations.with_access.where(advisor_company_id: advisor_company.id).should exist
    end

    context 'when the invited company is already advises' do
      before { company.invite_advisor(advisor_company) }

      it 'should return invalid affiliation object' do
        expect do
          affiliation = company.invite_advisor(advisor_company)
          affiliation.should_not be_valid
        end.not_to change(company.reload.advisor_company_affiliations, :count)
      end
    end
  end

end
