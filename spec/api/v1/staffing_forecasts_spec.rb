require 'spec_helper'

describe 'API v1 for staffing_forecasts', :api do
  include_context 'stuff for the API integration specs'

  let!(:scenario)                 { create(:scenario, company: first_company) }
  let!(:employee_type)            { create(:employee_type, company: first_company) }

  let!(:staffing_forecast)        { create(:staffing_forecast, company: first_company, id: '4fdf2a14b0207a25dd000003',
                                            scenario: scenario, employee_type: employee_type, occurrence: 'Monthly') }
  let!(:second_staffing_forecast) { create(:staffing_forecast, company: first_company, id: '17cc67093475061e3d95369d',
                                            occurrence_month: 9, revenue_threshold: 2, occurrence: 'Annually') }
  let!(:third_staffing_forecast)  { create(:staffing_forecast, company: first_company, occurrence: 'Fixed') }
  let!(:fourth_staffing_forecast) { create(:staffing_forecast, company: first_company, occurrence: 'Revenue Threshold') }
  let!(:fifth_staffing_forecast)  { create(:staffing_forecast, company: second_company) }

  describe 'GET /api/v1/staffing_forecasts.json' do
    it_should_have_api_endpoint path: 'staffing_forecasts'

    let(:url) { api_v1_staffing_forecasts_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [staffing_forecast, second_staffing_forecast, third_staffing_forecast, fourth_staffing_forecast] }
        let(:second_group) { [fifth_staffing_forecast] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/staffing_forecasts/:id.json' do
    it_should_have_api_endpoint { "staffing_forecasts/#{staffing_forecast.id}" }

    let(:url) { api_v1_staffing_forecast_url(staffing_forecast, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      let(:url) { api_v1_staffing_forecast_url(forecast, format: :json, subdomain: company.subdomain) }
      let(:forecast) { staffing_forecast }

      subject { response.body }

      it { should_not have_json_path('company_id') }
      it { should have_json_value(scenario.id.to_s).at_path('scenario_id') }
      it { should have_json_value(employee_type.id.to_s).at_path('employee_type_id') }
      it { should have_json_value(staffing_forecast.occurrence).at_path('occurrence') }

      it_behaves_like 'forecast with occurrence', 'Monthly', ['fixed_delta'],
                      ['occurrence_month', 'occurrence_period_id', 'revenue_threshold'] do
        let(:forecast) { staffing_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Annually', ['fixed_delta', 'occurrence_month'],
                      ['occurrence_period_id', 'revenue_threshold'] do
        let(:forecast) { second_staffing_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Fixed', ['fixed_delta', 'occurrence_period_id'],
                      ['occurrence_month', 'revenue_threshold'] do
        let(:forecast) { third_staffing_forecast }
      end

      it_behaves_like 'forecast with occurrence', 'Revenue Threshold', ['revenue_threshold'],
                      ['occurrence_period_id', 'fixed_delta', 'occurrence_month'] do
        let(:forecast) { fourth_staffing_forecast }
      end
    end
  end

  describe 'POST /api/v1/staffing_forecasts.json' do
    it_should_have_api_endpoint path: 'staffing_forecasts'

    let(:attributes) { { occurrence: 'Monthly', fixed_delta: 1,
                         scenario_id: scenario.id, employee_type_id: employee_type.id } }
    let(:url) { api_v1_staffing_forecasts_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, staffing_forecast: attributes
      end.to change(company.staffing_forecasts, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_staffing_forecast) { company.staffing_forecasts.last }

    describe 'created staffing_forecast' do
      subject { created_staffing_forecast }

      its(:occurrence)    { should == attributes[:occurrence] }
      its(:fixed_delta)   { should == attributes[:fixed_delta] }
      its(:scenario)      { should == scenario }
      its(:employee_type) { should == employee_type }
    end

    describe 'returned JSON' do
      subject { response.body }
      it { should be_json_eql(created_staffing_forecast.to_json) }
    end
  end

  describe 'PUT /api/v1/staffing_forecasts/:id.json' do
    it_should_have_api_endpoint { "staffing_forecasts/#{second_staffing_forecast.id}" }

    let(:attributes) { { occurrence: 'Revenue Threshold', revenue_threshold: 10000000,
                         scenario_id: scenario.id, employee_type_id: employee_type.id } }
    let(:url)        { api_v1_staffing_forecast_url(second_staffing_forecast, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, staffing_forecast: attributes
      end.not_to change(company.staffing_forecasts, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated staffing_forecast' do
      subject { second_staffing_forecast.reload }

      its(:occurrence)        { should == attributes[:occurrence] }
      its(:revenue_threshold) { should == attributes[:revenue_threshold] }
      its(:scenario)          { should == scenario }
      its(:employee_type)     { should == employee_type }

      context 'does not update not ocurrence attributes' do
        let(:attributes) { { occurrence: 'Fixed', occurrence_month: 12, revenue_threshold: 0.18 } }

        its(:occurrence)         { should == attributes[:occurrence] }
        its(:occurrence_month)   { should == 9 }
        its(:revenue_threshold)  { should == 2 }
      end
    end
  end

  describe 'DELETE /api/v1/staffing_forecasts/:id.json' do
    it_should_have_api_endpoint { "staffing_forecasts/#{second_staffing_forecast.id}" }

    let(:url) { api_v1_staffing_forecast_url(second_staffing_forecast, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.staffing_forecasts, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
