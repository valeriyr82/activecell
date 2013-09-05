require 'spec_helper'

describe CompanyInvitation do
  describe 'fields' do
    it { should have_field(:email).of_type(String) }
    it { should have_field(:token).of_type(String) }
  end

  describe 'associations' do
    it { should belong_to(:company).as_inverse_of(:invitations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).scoped_to(:company_id) }

    describe 'email uniqueness validation' do
      let(:company) { create(:company) }

      it 'should be valid is an user is not already invited' do
        invitation = build(:company_invitation, company: company)
        invitation.should be_valid
      end

      it 'should not be valid is na user is already invited' do
        create(:company_invitation, company: company, email: 'new@user.com')
        invitation = build(:company_invitation, company: company, email: 'new@user.com')
        invitation.should_not be_valid
        invitation.errors[:email].should include('is already invited')
      end
    end

    describe 'user_is_not_registered' do
      it 'should be valid when invited user does not have an account' do
        invitation = build(:company_invitation, email: 'new@user.com')
        invitation.should be_valid
      end

      it 'should not be valid when invited user has an account' do
        create(:user, email: 'existing@user.com')
        invitation = build(:company_invitation, email: 'existing@user.com')
        invitation.should_not be_valid
        invitation.errors[:email].should include('is already registered')
      end
    end
  end

  describe 'callbacks' do
    describe 'invitation token generation' do
      let(:invitation) { build(:company_invitation) }
      before { Digest::SHA1.stub(hexdigest: 'the token') }

      specify do
        expect do
          invitation.save
        end.to change(invitation, :token).from(nil).to('the token')
      end
    end
  end
end
