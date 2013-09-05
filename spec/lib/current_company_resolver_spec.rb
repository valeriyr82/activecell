require 'spec_helper'

describe CurrentCompanyResolver do
  let(:subdomain) { 'test-subdomain' }
  let(:current_user) { mock_model(User) }
  subject(:resolver) { described_class.new(subdomain, current_user) }

  its(:request_subdomain) { should == subdomain }
  its(:current_user) { should == current_user }

  describe '#resolve' do
    let(:company) { mock_model(Company) }

    context 'when subdomain is present' do
      before do
        Company.should_receive(:find_by_subdomain).with(subdomain).and_return(company)
      end

      it 'finds a company by subdomain name' do
        resolver.resolve.should == company
      end
    end

    context 'when subdomain is not present' do
      let(:subdomain) { nil }

      context 'but current user is given' do
        let(:first_company) { mock_model(Company) }
        before { current_user.should_receive(:first_company).and_return(first_company) }

        it "return current user's first company" do
          resolver.resolve.should == first_company
        end
      end

      context 'and current user is not present' do
        let(:current_user) { nil }

        it 'returns nil' do
          resolver.resolve.should == nil
        end
      end
    end
  end
end
