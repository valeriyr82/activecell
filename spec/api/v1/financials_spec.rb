require 'spec_helper'

describe 'API v1 for financial transactions/summary', :api do
  include_context 'stuff for the API integration specs'

  let!(:period)           { create(:period) }
  let!(:account)          { create(:account,  company: first_company) }
  let!(:product)          { create(:product,  company: first_company) }
  let!(:customer)         { create(:customer, company: first_company) }
  let!(:employee)         { create(:employee, company: first_company) }
  let!(:vendor)           { create(:vendor,   company: first_company) }

  let!(:financial)        { create(:financial_transaction, company: first_company, amount_cents: 10000,
                                    id: '17cc67093475061e3d95369d', period: period, account: account,
                                    product: product, employee: employee, vendor: vendor, customer: customer,
                                    document_type: 'Quickbooks Desktop Invoice', document_id: '100a',
                                    document_line: '3b', transaction_date: '2012-01-01') }
  let!(:second_financial) { create(:financial_transaction, company: first_company, amount_cents: 30000,
                                    id: '4fdf2a14b0207a25dd000002', period: period, account: account,
                                    product: product, employee: employee, vendor: vendor, customer: customer) }
  let!(:third_financial)  { create(:financial_transaction, company: first_company) }
  let!(:fourth_financial) { create(:financial_transaction, company: second_company,
                                    id: '5a3s2a14b0207a25dd123433', period: period, account: account,
                                    product: product, employee: employee, vendor: vendor, customer: customer) }

  describe 'GET /api/v1/financial_summary.json' do
    it_should_have_api_endpoint path: 'financial_summary'

    let(:url) { api_v1_financial_summary_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_and_second_financial) { {} }
        let(:first_group)  { [first_and_second_financial, third_financial] }
        let(:second_group) { [fourth_financial] }
      end

      describe 'returned JSON' do
        subject { response.body }
        let(:amount_cents) { financial.amount_cents + second_financial.amount_cents }

        it { should_not have_json_path('0/id') }
        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(amount_cents.to_f).at_path('0/amount_cents') }
        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(account.id.to_s).at_path('0/account_id') }
        it { should have_json_value(product.id.to_s).at_path('0/product_id') }
        it { should have_json_value(employee.id.to_s).at_path('0/employee_id') }
        it { should have_json_value(vendor.id.to_s).at_path('0/vendor_id') }
        it { should have_json_value(customer.id.to_s).at_path('0/customer_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/financial_transactions.json?period_id=17cc67093475061e3d95369d&&account_id=...' do
    let(:url) { api_v1_financial_transactions_url(format: :json, subdomain: company.subdomain,
                                                  period_id: period.id, account_id: account.id, product_id: product.id,
                                                  employee_id: employee.id, vendor_id: vendor.id, customer_id: customer.id) }

    describe 'endpoint url' do
      subject { url }
      it { should == "http://#{company.subdomain}.example.com/api/v1/financial_transactions.json?account_id=#{account.id}" + \
                     "&customer_id=#{customer.id}&employee_id=#{employee.id}" + \
                     "&period_id=#{period.id}&product_id=#{product.id}&vendor_id=#{vendor.id}" }
    end

    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [financial, second_financial] }
        let(:second_group) { [fourth_financial] }
      end

      describe 'returned JSON' do
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(financial.id.to_s).at_path('0/id') }
        it { should have_json_value(financial.amount_cents).at_path('0/amount_cents') }
        it { should have_json_value(financial.document_type).at_path('0/document_type') }
        it { should have_json_value(financial.document_id).at_path('0/document_id') }
        it { should have_json_value(financial.document_line).at_path('0/document_line') }
        it { should have_json_value(financial.transaction_date).at_path('0/transaction_date') }

        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(account.id.to_s).at_path('0/account_id') }
        it { should have_json_value(product.id.to_s).at_path('0/product_id') }
        it { should have_json_value(employee.id.to_s).at_path('0/employee_id') }
        it { should have_json_value(vendor.id.to_s).at_path('0/vendor_id') }
        it { should have_json_value(customer.id.to_s).at_path('0/customer_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end
end
