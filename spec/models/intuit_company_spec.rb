require 'spec_helper'

describe IntuitCompany, :intuit do
  let(:intuit_company) { build(:intuit_company) }
  subject { intuit_company }

  describe 'fields' do
    it { should have_field(:realm).of_type(Integer) }
    it { should have_field(:access_token).of_type(String) }
    it { should have_field(:access_secret).of_type(String) }
    it { should have_field(:provider).of_type(String) }
    it { should have_field(:connected_at).of_type(Time) }
  end

  describe 'validations' do
    it { should validate_presence_of(:realm) }
    it { should validate_uniqueness_of(:realm) }
    it { should validate_presence_of(:provider) }
  end

  describe 'associations' do
    it { should be_embedded_in(:company) }
  end

  describe '.find_by_realm' do
    it 'should try to find a intuit company by realm' do
      IntuitCompany.should_receive(:where).with(realm: 'the realm').and_return(subject)
      result = IntuitCompany.find_by_realm('the realm')
      result.should == subject
    end
  end

  describe '#token_expired?' do
    it { should respond_to(:token_expired?) }

    describe 'result' do
      subject { intuit_company.token_expired? }
      before { intuit_company.connected_at = connected_at }

      context 'when token was generated more than 6 months ago' do
        let(:connected_at) { 6.months.ago }
        it { should be_true }
      end

      context 'when token was generated in 6 months' do
        let(:connected_at) { 1.day.ago }
        it { should be_false }
      end

      context 'when never connected' do
        let(:connected_at) { nil }
        it { should be_false }
      end
    end
  end

  describe '#oauth_token' do
    it { should respond_to(:oauth_token) }
    its(:oauth_token) { should be_an_instance_of(OAuth::AccessToken) }
  end

  describe '#disconnect!' do
    subject { create(:intuit_company, :with_company) }
    it { should respond_to(:disconnect!) }

    before { subject.disconnect! }
    its(:access_token) { should be_nil }
    its(:access_secret) { should be_nil }
    its(:connected_at) { should be_nil }
  end
end
