require 'spec_helper'

describe 'API v1 for accounts', :api do
  include_context 'stuff for the API integration specs'

  let!(:account)        { create(:account, company: first_company, id: '4fdf2a14b0207a25dd000003',
                                           name: 'Primary Checking Account', type: 'Expense', sub_type: 'Payroll',
                                           current_balance: 200, current_balance_currency: 'USD',
                                           account_number: '8237a', is_active: true) }
  let!(:second_account) { create(:account, company: first_company, id: '17cc67093475061e3d95369d') }
  let!(:third_account)  { create(:account, company: second_company) }

  describe 'GET /api/v1/accounts.json' do
    it_should_have_api_endpoint path: 'accounts'

    let(:url) { api_v1_accounts_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [account, second_account] }
        let(:second_group) { [third_account] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/accounts/:id.json' do
    it_should_have_api_endpoint { "accounts/#{account.id}" }

    let(:url) { api_v1_account_url(account, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(account.name).at_path('name') }
      it { should have_json_value(account.type).at_path('type') }
      it { should have_json_value(account.sub_type).at_path('sub_type') }
      it { should have_json_value(account.account_number).at_path('account_number') }
      it { should have_json_value(account.current_balance).at_path('current_balance') }
      it { should have_json_value(account.current_balance_currency).at_path('current_balance_currency') }
      it { should have_json_value(account.is_active).at_path('is_active') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/accounts.json' do
    it_should_have_api_endpoint path: 'accounts'

    let(:attributes) { { name: 'Payroll', type: 'Non-Posting', sub_type: 'Payroll', parent_account_id: second_account.id, account_number: 'ashjk1', is_active: true } }
    let(:url) { api_v1_accounts_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, account: attributes
      end.to change(company.accounts, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_account) { company.accounts.last }

    describe 'created account' do
      subject { created_account }

      its(:company)        { should == first_company }
      its(:name)           { should == attributes[:name] }
      its(:type)           { should == attributes[:type] }
      its(:sub_type)       { should == attributes[:sub_type] }
      its(:account_number) { should == attributes[:account_number] }
      its(:parent_account) { should == second_account }
      its(:is_active)      { should == attributes[:is_active] }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the account' do
        should be_json_eql(created_account.to_json)
      end
    end
  end

  describe 'PUT /api/v1/accounts/:id.json' do
    it_should_have_api_endpoint { "accounts/#{second_account.id}" }

    let(:attributes) { { name: 'Wages and Salaries', type: 'Expense', sub_type: 'Payroll', account_number: '8237b', parent_account_id: account.id, is_active: true } }
    let(:url)        { api_v1_account_url(second_account, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, account: attributes
      end.not_to change(company.accounts, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated account' do
      subject { second_account.reload }

      its(:name)           { should == attributes[:name] }
      its(:type)           { should == attributes[:type] }
      its(:sub_type)       { should == attributes[:sub_type] }
      its(:account_number) { should == attributes[:account_number] }
      its(:parent_account) { should == account }
      its(:is_active)      { should == attributes[:is_active] }

      context 'with invalid type' do
        let(:attributes) { { type: 'Something Strange'} }
        it_behaves_like 'an API request with response status', :unprocessable_entity
      end
    end
  end

  describe 'DELETE /api/v1/accounts/:id.json' do
    it_should_have_api_endpoint { "accounts/#{second_account.id}" }

    let(:url) { api_v1_account_url(second_account, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.accounts, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
