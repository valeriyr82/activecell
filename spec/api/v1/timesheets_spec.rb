require 'spec_helper'

describe 'API v1 for timesheet transactions/summary', :api do
  include_context 'stuff for the API integration specs'

  let!(:period)            { create(:period) }
  let!(:employee_activity) { create(:employee_activity) }
  let!(:product)           { create(:product,  company: first_company) }
  let!(:customer)          { create(:customer, company: first_company) }
  let!(:employee)          { create(:employee, company: first_company) }

  let!(:timesheet)         { create(:timesheet_transaction, company: first_company, amount_minutes: 120,
                                     period: period, employee_activity: employee_activity,
                                     product: product, employee: employee, customer: customer,
                                     document_type: 'Quickbooks Desktop Timesheet', document_id: '100a',
                                     document_line: '3b', transaction_date: '2012-01-01') }
  let!(:second_timesheet)  { create(:timesheet_transaction, company: first_company, amount_minutes: 240,
                                     period: period, employee_activity: employee_activity,
                                     product: product, employee: employee, customer: customer) }
  let!(:fourth_timesheet)  { create(:timesheet_transaction, company: second_company,
                                     period: period, employee_activity: employee_activity,
                                     product: product, employee: employee, customer: customer) }

  describe 'GET /api/v1/timesheet_summary.json' do
    it_should_have_api_endpoint path: 'timesheet_summary'

    let(:url) { api_v1_timesheet_summary_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_and_second_timesheet) { {} }
        let(:first_group)  { [first_and_second_timesheet] }
        let(:second_group) { [fourth_timesheet] }
      end

      describe 'returned JSON' do
        subject { response.body }
        let(:amount_minutes) { timesheet.amount_minutes + second_timesheet.amount_minutes }

        it { should_not have_json_path('0/id') }
        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(amount_minutes.to_f).at_path('0/amount_minutes') }
        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(product.id.to_s).at_path('0/product_id') }
        it { should have_json_value(employee.id.to_s).at_path('0/employee_id') }
        it { should have_json_value(employee_activity.id.to_s).at_path('0/employee_activity_id') }
        it { should have_json_value(customer.id.to_s).at_path('0/customer_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/timesheet_transactions.json?period_id=17cc67093475061e3d95369d&&product_id=...' do
    let(:url) { api_v1_timesheet_transactions_url(format: :json, subdomain: company.subdomain,
                                                  period_id: period.id, product_id: product.id, employee_id: employee.id,
                                                  employee_activity_id: employee_activity.id, customer_id: customer.id) }

    describe 'endpoint url' do
      subject { url }
      it { should == "http://#{company.subdomain}.example.com/api/v1/timesheet_transactions.json?" + \
                     "customer_id=#{customer.id}&employee_activity_id=#{employee_activity.id}&" + \
                     "employee_id=#{employee.id}&period_id=#{period.id}&product_id=#{product.id}" }
    end

    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [timesheet, second_timesheet] }
        let(:second_group) { [fourth_timesheet] }
      end

      describe 'returned JSON' do
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(timesheet.id.to_s).at_path('0/id') }
        it { should have_json_value(timesheet.amount_minutes).at_path('0/amount_minutes') }
        it { should have_json_value(timesheet.document_type).at_path('0/document_type') }
        it { should have_json_value(timesheet.document_id).at_path('0/document_id') }
        it { should have_json_value(timesheet.document_line).at_path('0/document_line') }
        it { should have_json_value(timesheet.transaction_date).at_path('0/transaction_date') }

        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(product.id.to_s).at_path('0/product_id') }
        it { should have_json_value(employee.id.to_s).at_path('0/employee_id') }
        it { should have_json_value(employee_activity.id.to_s).at_path('0/employee_activity_id') }
        it { should have_json_value(customer.id.to_s).at_path('0/customer_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end
end
