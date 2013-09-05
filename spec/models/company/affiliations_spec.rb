require 'spec_helper'

describe Company::Affiliations, :advisor do
  let!(:company) { create(:company) }
  subject { company }

  describe 'associations' do
    let!(:advisor_company) { create(:advisor_company) }
    let!(:other_company) { create(:company) }

    it { should have_many(:company_affiliations).of_type(CompanyAffiliation) }

    describe '#advisor_company_affiliations' do
      it do
        should have_many(:advisor_company_affiliations).
                   of_type(AdvisorCompanyAffiliation).as_inverse_of(:company)
      end

      describe 'after #destroy' do
        before { company.invite_advisor(advisor_company) }

        it 'should remove obsolete affiliations' do
          advisor_company.destroy
          company.reload

          affiliations = company.advisor_company_affiliations.where(advisor_company: advisor_company)
          affiliations.should be_empty
        end
      end

      describe 'returned list' do
        shared_examples 'for company with one advisor' do
          it { should have(1).item }

          it 'should include an advisor company affiliation' do
            result.first.company_id.should == company.id
            result.first.advisor_company_id.should == advisor_company.id
          end
        end

        let(:result) { company.advisor_company_affiliations }
        subject { result }

        context 'when the company does not have any affiliations' do
          it { should be_empty }
        end

        context 'when the company has an advisor' do
          before { company.invite_advisor(advisor_company) }

          include_examples 'for company with one advisor'

          context 'but the advisor has downgraded his account' do
            before { advisor_company.downgrade_from_advisor! }
            let(:result) { company.reload.advisor_company_affiliations }

            it 'should not include downgraded advisor company' do
              should be_empty
            end

            it 'should mark all previous affiliations as deleted' do
              deleted = company.advisor_company_affiliations.deleted

              deleted.should_not be_empty
              deleted.first.company_id.should == company.id
              deleted.first.advisor_company_id.should == advisor_company.id
            end

            context 'and he downgraded once again' do
              before { advisor_company.upgrade_to_advisor! }
              let(:result) { company.reload.advisor_company_affiliations }

              include_examples 'for company with one advisor'
            end
          end
        end
      end
    end

    describe '#user_affiliations' do
      it do
        should have_many(:user_affiliations).
                   of_type(UserAffiliation)
      end

      let!(:first_user) { create(:user) }
      let!(:second_user) { create(:user) }

      describe 'returned list' do
        let(:result) { company.user_affiliations }
        subject { result }

        context 'when the company has no users' do
          it { should be_empty }
        end

        context 'when the company has one user' do
          before { company.invite_user(first_user) }

          it { should have(1).item }
          specify { company.advisor_company_affiliations.should be_empty }

          it 'should include affiliation for the given user' do
            result.first.company.should == company
            result.first.user.should == first_user
          end
        end
      end
    end
  end

  describe '#users' do
    it { should respond_to(:users) }

    describe 'result' do
      let(:first_user) { create(:user, created_at: 2.days.ago) }
      let(:second_user) { create(:user, created_at: 1.month.ago) }
      let(:third_user) { create(:user, created_at: 5.minutes.ago) }
      let(:other_user) { create(:user) }

      before do
        company.invite_user(first_user)
        company.invite_user(second_user)
        company.invite_user(third_user)
      end

      let(:result) { company.users }
      subject { result }

      it { should have(3).items }

      it 'should include all company users' do
        should include(first_user)
        should include(second_user)
        should include(third_user)
      end

      it 'should be sorted by :created_at field' do
        expect(result.first).to eq(second_user)
        expect(result.second).to eq(first_user)
        expect(result.third).to eq(third_user)
      end

      it 'should not include users outside the company' do
        should_not include(other_user)
      end

      context 'when an access was revoked' do
        let(:affiliation) { company.user_affiliations.where(user: third_user).first }
        before { affiliation.update_attributes(has_access: false) }

        it 'should not include users without access' do
          should have(2).items

          should include(first_user)
          should include(second_user)
          should_not include(third_user)
        end
      end

      context 'when the company has some advisors' do
        let(:first_advisor_user) { create(:user) }
        let(:second_advisor_user) { create(:user) }
        let(:third_advisor_user) { create(:user) }

        let(:first_advisor_company) { create(:advisor_company, users: [first_advisor_user, second_advisor_user]) }
        let(:second_advisor_company) { create(:advisor_company, users: [third_advisor_user, second_advisor_user]) }

        before do
          company.invite_advisor(first_advisor_company)
          company.invite_advisor(second_advisor_company)
        end

        it { should have(6).items }

        it 'should include advisor companies users' do
          should include(first_advisor_user)
          should include(second_advisor_user)
          should include(third_advisor_user)
        end

        it 'should include all company users' do
          should include(first_user)
          should include(second_user)
          should include(third_user)
        end

        context 'when an access for one of advisor users was revoked' do
          let(:affiliation) { first_advisor_company.user_affiliations.where(user: first_advisor_user).first }
          before { affiliation.update_attributes(has_access: false) }

          it { should have(5).items }

          it 'should not include an user without an access' do
            should_not include(first_advisor_user)
          end
        end

        context 'when an access for advisor was revoked' do
          let(:affiliation) { company.advisor_company_affiliations.where(advisor_company: second_advisor_company).first }
          before { affiliation.update_attributes(has_access: false) }

          it { should have(5).items }

          it 'should not include users from this advisor company' do
            should_not include(third_advisor_user)
          end
        end

        context 'when an advisor user belongs to two advisor companies and his access was revoked' do
          let(:affiliation) { first_advisor_company.user_affiliations.where(user: second_advisor_user).first }
          before { affiliation.update_attributes(has_access: false) }

          it { should have(6).items }

          it 'should be included in the result' do
            should include(second_advisor_user)
          end
        end
      end
    end
  end

  describe "#first_user" do
    it { should respond_to(:first_user) }

    let(:first_user) { mock_model(User) }
    let(:second_user) { mock_model(User) }
    before { company.stub(users: [first_user, second_user]) }

    it 'should return just the first user' do
      expect(company.first_user).to eq(first_user)
    end
  end

  describe '#advised?' do
    it { should respond_to(:advised?) }

    describe 'result' do
      subject { company.advised? }

      context 'when the company is not advised' do
        it { should be_false }
      end

      context 'when the company is advised' do
        let!(:advisor_company) { create(:advisor_company) }
        before { company.invite_advisor(advisor_company) }

        it { should be_true }
      end
    end
  end

  describe '#advisor_companies' do
    it { should respond_to(:advisor_companies) }

    describe 'returned list' do
      let(:result) { company.advisor_companies }
      subject { result }

      context 'when the company does not have any advisors' do
        it { should be_empty }
      end

      context 'when the company belongs to one advisor' do
        let!(:advisor_company) { create(:advisor_company) }
        before { company.invite_advisor(advisor_company) }

        it { should have(1).item }

        it 'should include the advisor' do
          should include(advisor_company)
        end
      end

      context 'when the company belongs to one or more advisors' do
        let!(:first_advisor_company) { create(:advisor_company) }
        let!(:second_advisor_company) { create(:advisor_company) }

        before do
          company.invite_advisor(first_advisor_company)
          company.invite_advisor(second_advisor_company)
        end

        it { should have(2).items }

        it 'should include the first advisor' do
          should include(first_advisor_company)
        end

        it 'should include the first advisor' do
          should include(second_advisor_company)
        end

        context 'when an access for one of advisor was revoked' do
          before do
            affiliation = company.advisor_company_affiliations.where(advisor_company_id: first_advisor_company.id).first
            affiliation.update_attribute(:has_access, false)
          end

          it { should have(1).item }

          it 'should include an advisor with granted access' do
            should include(second_advisor_company)
            should_not include(first_advisor_company)
          end
        end

        context 'when one of advisors downgraded his account' do
          before { second_advisor_company.downgrade_from_advisor! }

          it { should have(1).item }

          it 'should include only advisors' do
            should include(first_advisor_company)
            should_not include(second_advisor_company)
          end
        end
      end
    end
  end

end
