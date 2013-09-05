require 'spec_helper'

describe User::Affiliations, :advisor do
  let(:user) { create(:user) }
  subject { user }

  it { should have_many(:company_affiliations).of_type(UserAffiliation).with_dependent(:destroy) }

  describe '#companies' do
    it { should respond_to(:companies) }

    describe 'result' do
      let!(:first_company) { create(:company) }
      let!(:second_company) { create(:company) }

      subject { user.companies }

      context 'when the user does not belong to any company' do
        it { should be_empty }
      end

      context 'when the belongs to one company' do
        before { first_company.invite_user(user) }

        it { should have(1).item }
        it('should include this company') { should include(first_company) }
        it('should not include other company') { should_not include(second_company) }

        context 'when other company was added' do
          before { second_company.invite_user(user) }

          it { should have(2).items }
          it('should include other company') { should include(second_company) }

          context 'when an access was revoked' do
            before do
              first_company_affiliation = second_company.company_affiliations.where(company: first_company).first
              first_company_affiliation.update_attribute(:has_access, false)
            end

            it { should have(1).items }
            it('should not include revoked company') { should_not include(first_company) }
            it('should include other company') { should include(second_company) }
          end
        end
      end
    end
  end

  describe '#advisor_companies' do
    let!(:first_company) { create(:company) }
    let!(:second_company) { create(:advisor_company) }

    before do
      first_company.invite_user(user)
      second_company.invite_user(user)
    end

    it "should return a list of user's advisor companies" do
      advisor_companies = user.advisor_companies
      advisor_companies.should have(1).item
      advisor_companies.should_not include(first_company)
      advisor_companies.should include(second_company)
    end
  end

  describe '#advised_companies' do
    let!(:advisor_company) { create(:advisor_company) }
    before { advisor_company.invite_user(user) }

    describe 'result' do
      let!(:first_company) { create(:company) }
      let!(:second_company) { create(:company) }

      subject { user.advised_companies }

      context 'without any advised companies' do
        it { should be_empty }
      end

      context 'with advised companies' do
        before { first_company.invite_advisor(advisor_company) }

        it 'should return a list of companies to which an user has access as an advisor' do
          should have(1).item
          should include(first_company)
          should_not include(second_company)
          should_not include(advisor_company)
        end

        context 'when an access was revoked' do
          before do
            # first_company revokes an advisory access for advisor_company
            affiliation = first_company.advisor_company_affiliations.where(advisor_company: advisor_company).first
            affiliation.update_attribute(:has_access, false)
          end

          it 'should not include a company with revoked access' do
            should be_empty
            should_not include(first_company)
          end
        end

        context 'when two advisor companies advises the same company' do
          let!(:other_advisor_company) { create(:advisor_company) }
          before do
            other_advisor_company.invite_user(user)
            first_company.invite_advisor(other_advisor_company)
          end

          it 'should include advised company only once' do
            should have(1).item
            should include(first_company)
          end
        end
      end
    end
  end

  describe '#is_advisor?' do
    it { should respond_to(:is_advisor?) }

    describe 'result' do
      let!(:company) { create(:company) }
      let!(:advisor_company) { create(:advisor_company) }

      subject { user.is_advisor? }

      context 'when an user does not belong to any company' do
        it { should be_false }
      end

      context 'when an user belongs to company but it is not an advisor' do
        before { company.invite_user(user) }
        it { should be_false }
      end

      context 'when an user belongs to at least one advisor company' do
        before do
          company.invite_user(user)
          advisor_company.invite_user(user)
        end

        it { should be_true }
      end
    end
  end

  describe "#first_company" do
    it { should respond_to(:first_company) }

    describe 'result' do
      let!(:first_company) { create(:company) }
      let!(:second_company) { create(:company) }
      let!(:other_company) { create(:company) }
      subject { user.first_company }

      context 'when an user belongs to at least one company' do
        before do
          first_company.invite_user(user)
          second_company.invite_user(user)
        end

        it 'should return the first company' do
          should == first_company
        end

        it "should not return the second user's company" do
          should_not == second_company
        end

        it 'should not include other company' do
          should_not == other_company
        end
      end

      context 'otherwise' do
        it { should be_nil }
      end
    end
  end

  describe '#without_company?' do
    it { should respond_to(:without_company?) }

    describe 'result' do
      subject { user.without_company? }

      context 'when an user belongs to at least one company' do
        let!(:company) { create(:company) }
        before { company.invite_user(user) }

        it { should be_false }
      end

      context 'otherwise' do
        it { should be_true }
      end
    end
  end

  describe '#has_subdomain?' do
    it { should respond_to(:has_subdomain?) }

    describe 'result' do
      let!(:first_company) { create(:advisor_company, name: 'First', subdomain: 'first') }
      let!(:second_company) { create(:company, name: 'Second', subdomain: 'second') }
      let!(:other_company) { create(:company, subdomain: 'third') }
      let(:user) { create(:user) }

      subject { user.has_subdomain?(subdomain) }

      context 'when the given subdomain belongs to the user' do
        before do
          first_company.invite_user(user)
          second_company.invite_user(user)
        end

        context do
          let(:subdomain) { 'first' }
          it { should be_true }
        end

        context do
          let(:subdomain) { 'second' }
          it { should be_true }
        end

        context 'but an access was revoked' do
          before do
            affiliation = second_company.user_affiliations.first
            affiliation.update_attribute(:has_access, false)
          end

          context do
            let(:subdomain) { 'first' }
            it { should be_true }
          end

          context do
            let(:subdomain) { 'second' }
            it { should be_false }
          end
        end
      end

      context 'when an user has advisory access' do
        before do
          first_company.invite_user(user)
          first_company.become_an_advisor_for(second_company)
        end

        context do
          let(:subdomain) { 'first' }
          it { should be_true }
        end

        context do
          let(:subdomain) { 'second' }
          it { should be_true }
        end

        context 'but an access was revoked' do
          before do
            affiliation = first_company.advised_company_affiliations.first
            affiliation.update_attribute(:has_access, false)
          end

          context do
            let(:subdomain) { 'first' }
            it { should be_true }
          end

          context do
            let(:subdomain) { 'second' }
            it { should be_false }
          end
        end

        context 'but the company was deleted' do
          before { second_company.destroy }

          context do
            let(:subdomain) { 'first' }
            it { should be_true }
          end

          context do
            let(:subdomain) { 'second' }
            it { should be_false }
          end
        end
      end

      context 'when an user does not have any companies' do
        let(:subdomain) { 'third' }
        it { should be_false }
      end
    end
  end

  describe '#destroy' do
    let!(:first_company) { create(:company, users: [user]) }
    let!(:second_company) { create(:company, users: [user]) }

    it 'should remove existing affiliations with companies' do
      user.destroy

      first_company.reload.user_affiliations.should be_empty
      second_company.reload.user_affiliations.should be_empty
    end
  end

end
