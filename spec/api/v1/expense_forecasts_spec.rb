require 'spec_helper'

describe 'API v1 for expense_forecasts', :api do
  include_context 'stuff for the API integration specs'

  before do
    fixtures = SmartFixtures.instance
    fixtures.capture('API integration specs for expense_forecasts') do
      scenario = create(:scenario, company: first_company)
      category = create(:category, company: first_company)

      create(:expense_forecast, company: first_company, id: '4fdf2',
             scenario: scenario, category: category, occurrence: 'Monthly')
      create(:expense_forecast, company: first_company, id: '17cc6',
             occurrence_month: 10, percent_revenue: 0.1, occurrence: 'Annually', fixed_cost: 200)
      create(:expense_forecast, company: first_company, occurrence: 'Fixed')
      create(:expense_forecast, company: first_company, occurrence: 'Revenue Percent')
      create(:expense_forecast, company: first_company, occurrence: 'Employee Count')
      create(:expense_forecast, company: second_company)
    end
  end

  let(:scenario) { first_company.scenarios.last }
  let(:category) { first_company.categories.last }

  let(:expense_forecast)        { first_company.expense_forecasts[0] }
  let(:second_expense_forecast) { first_company.expense_forecasts[1] }
  let(:third_expense_forecast)  { first_company.expense_forecasts[2] }
  let(:fourth_expense_forecast) { first_company.expense_forecasts[3] }
  let(:fifth_expense_forecast)  { first_company.expense_forecasts[4] }
  let(:sixth_expense_forecast)  { second_company.expense_forecasts.first }

  describe 'GET /api/v1/expense_forecasts.json' do
    it_should_have_api_endpoint path: 'expense_forecasts'

    let(:url) { api_v1_expense_forecasts_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [expense_forecast, second_expense_forecast, third_expense_forecast,
                              fourth_expense_forecast, fifth_expense_forecast] }
        let(:second_group) { [sixth_expense_forecast] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/expense_forecasts/:id.json' do
    it_should_have_api_endpoint { "expense_forecasts/#{expense_forecast.id}" }

    let(:url) { api_v1_expense_forecast_url(expense_forecast, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      let(:url) { api_v1_expense_forecast_url(forecast, format: :json, subdomain: company.subdomain) }
      let(:forecast) { expense_forecast }

      subject { response.body }

      it { should_not have_json_path('company_id') }
      it { should have_json_value(expense_forecast.id).at_path('id') }
      it { should have_json_value(expense_forecast.name).at_path('name') }
      it { should have_json_value(expense_forecast.scenario_id.to_s).at_path('scenario_id') }
      it { should have_json_value(expense_forecast.category_id.to_s).at_path('category_id') }
      it { should have_json_value(expense_forecast.occurrence).at_path('occurrence') }

      it_behaves_like 'forecast with occurrence', 'Monthly', ['fixed_cost'],
                      ['occurrence_month', 'occurrence_period_id', 'percent_revenue'] do
        let(:forecast) { expense_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Annually', ['fixed_cost', 'occurrence_month'],
                      ['occurrence_period_id', 'percent_revenue'] do
        let(:forecast) { second_expense_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Fixed', ['fixed_cost', 'occurrence_period_id'],
                      ['occurrence_month', 'percent_revenue'] do
        let(:forecast) { third_expense_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Revenue Percent', ['percent_revenue'],
                      ['fixed_cost', 'occurrence_month', 'occurrence_period_id'] do
        let(:forecast) { fourth_expense_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Employee Count', ['fixed_cost'],
                      ['percent_revenue', 'occurrence_month', 'occurrence_period_id'] do
        let(:forecast) { fifth_expense_forecast }
      end
    end
  end

  describe 'POST /api/v1/expense_forecasts.json' do
    it_should_have_api_endpoint path: 'expense_forecasts'

    let(:attributes) { { name: 'Holiday party', occurrence: 'Annually', occurrence_month: 12, fixed_cost: 200000,
                         scenario_id: scenario.id, category_id: category.id } }
    let(:url) { api_v1_expense_forecasts_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, expense_forecast: attributes
      end.to change(company.expense_forecasts, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_expense_forecast) { company.expense_forecasts.last }

    describe 'created expense_forecast' do
      subject { created_expense_forecast }

      its(:name)             { should == attributes[:name] }
      its(:occurrence)       { should == attributes[:occurrence] }
      its(:occurrence_month) { should == attributes[:occurrence_month] }
      its(:fixed_cost)       { should == attributes[:fixed_cost] }
      its(:scenario)         { should == scenario }
      its(:category)         { should == category }
    end

    describe 'returned JSON' do
      subject { response.body }
      it { should be_json_eql(created_expense_forecast.to_json) }
    end
  end

  describe 'PUT /api/v1/expense_forecasts/:id.json' do
    it_should_have_api_endpoint { "expense_forecasts/#{second_expense_forecast.id}" }

    let!(:period)    { create(:period) }
    let(:attributes) { { name: 'Office Buildout', occurrence: 'Fixed', occurrence_period_id: period.id,
                         fixed_cost: 3100000, scenario_id: scenario.id, category_id: category.id } }
    let(:url)        { api_v1_expense_forecast_url(second_expense_forecast, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, expense_forecast: attributes
      end.not_to change(company.expense_forecasts, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated expense forecast' do
      subject { second_expense_forecast.reload }

      its(:name)              { should == attributes[:name] }
      its(:occurrence)        { should == attributes[:occurrence] }
      its(:fixed_cost)        { should == attributes[:fixed_cost] }
      its(:occurrence_period) { should == period }
      its(:scenario)          { should == scenario }
      its(:category)          { should == category }

      context 'does not update not ocurrence attributes' do
        let(:attributes) { { occurrence: 'Fixed', occurrence_month: 12, percent_revenue: 0.000125 } }

        its(:occurrence)       { should == attributes[:occurrence] }
        its(:occurrence_month) { should == 10 }
        its(:percent_revenue)  { should == 0.1 }
      end
    end
  end

  describe 'DELETE /api/v1/expense_forecasts/:id.json' do
    it_should_have_api_endpoint { "expense_forecasts/#{second_expense_forecast.id}" }

    let(:url) { api_v1_expense_forecast_url(second_expense_forecast, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.expense_forecasts, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
