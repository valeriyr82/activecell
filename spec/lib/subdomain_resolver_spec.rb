require 'spec_helper'

describe SubdomainResolver do
  let(:subdomain) { 'test-subdomain' }
  let!(:company)  { create(:company, subdomain: 'sterling-cooper')}
  let!(:user)     { create(:user, companies: [company]) }

  let(:resolver) { described_class.new(subdomain, user) }
  subject { resolver }

  describe "#not_belongs_to_user?" do
    it { should respond_to(:not_belongs_to_user?) }

    describe 'result' do
      let(:result) { resolver.not_belongs_to_user? }
      subject { result }

      context 'when user has subdomain' do
        let(:subdomain) { 'sterling-cooper' }
        it { should be_false }
      end

      context 'when the subdomain is blank' do
        let(:subdomain) { '' }
        it { should be_false }
      end

      context 'when the subdomain is reserved' do
        let(:subdomain) { 'www' }
        it { should be_false }
      end

      context 'when the user is blank' do
        let(:user) { nil }
        it { should be_true }
      end

      context 'when the user does not have a subdomain' do
        let(:subdomain) { 'other-subdomain' }
        it { should be_true }
      end
    end
  end
end
