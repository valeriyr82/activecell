require 'spec_helper'

describe User::IntuitSso, :intuit do
  let(:user) { create(:user) }
  subject { user }

  describe 'fields' do
    it { should have_field(:intuit_openid_identifier).of_type(String) }
  end

  describe '.new_from_auth_hash' do
    let(:intuit_openid_identifier) { 'https://openid.intuit.com/Identity-232840dc-9d6f-447d-a74a-5341f6598ac3' }
    let(:email) { 'new@email.com' }
    let(:name) { 'Test User' }

    let(:auth_hash) do
      {
          uid: intuit_openid_identifier,
          info: {
              email: email,
              name: name
          }
      }
    end

    describe 'result' do
      subject { User.new_from_auth_hash(auth_hash) }

      it { should be_an_instance_of(User) }
      it { should be_valid }

      its(:intuit_openid_identifier) { should == intuit_openid_identifier }
      its(:email) { should == email }
      its(:name) { should == name }
      its(:password) { should be_present }
    end
  end

  describe '#connected_with_intuit?' do
    it { should respond_to(:connected_with_intuit?) }

    describe 'result' do
      subject { user.connected_with_intuit? }

      context 'when intuit uid is present' do
        before { user.intuit_openid_identifier = 'some uid' }
        it { should be_true }
      end

      context 'otherwise' do
        before { user.intuit_openid_identifier = nil }
        it { should be_false }
      end
    end
  end

  describe '#initiate_intuit_company_connect?' do
    it { should respond_to(:initiate_intuit_company_connect?) }

    describe 'result' do
      subject { user.initiate_intuit_company_connect? }

      context 'when an user is connected with Intuit' do
        before { user.intuit_openid_identifier = 'some uid' }

        context 'when an user belongs to least one company' do
          let!(:company) { create(:company) }
          before { company.invite_user(user) }

          it { should be_false }
        end

        context 'when an user does not have any companies' do
          it { should be_true }
        end
      end

      context 'when an user is not connected with Intuit' do
        before { user.intuit_openid_identifier = nil }
        it { should be_false }
      end
    end
  end

end
