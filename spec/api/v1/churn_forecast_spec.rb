require 'spec_helper'

describe 'API v1 for conversion summary', :api do
  include_context 'stuff for the API integration specs'

  let!(:churn_forecast)        { create(:churn_forecast, company: first_company, id: '4fdf2a14b0207a25dd000003') }
  let!(:second_churn_forecast) { create(:churn_forecast, company: first_company) }

  let!(:period)                { create(:period) }
  let!(:scenario)              { create(:scenario, company: second_company) }
  let!(:segment)               { create(:segment, company: second_company) }
  let!(:third_churn_forecast)  { create(:churn_forecast, company: second_company, id: '17cc67093475061e3d95369d',
                                         churn_forecast: 72, period: period, scenario: scenario, segment: segment) }

  describe 'GET /api/v1/churn_forecast.json' do
    it_should_have_api_endpoint path: 'churn_forecast'

    let(:url) { api_v1_churn_forecast_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [churn_forecast, second_churn_forecast] }
        let(:second_group) { [third_churn_forecast] }
      end

      describe 'returned JSON' do
        let(:company) { second_company }
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(third_churn_forecast.id.to_s).at_path('0/id') }
        it { should have_json_value(third_churn_forecast.churn_forecast).at_path('0/churn_forecast') }
        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(scenario.id.to_s).at_path('0/scenario_id') }
        it { should have_json_value(segment.id.to_s).at_path('0/segment_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'PUT /api/v1/churn_forecast/:id.json' do
    it_should_have_api_endpoint { "churn_forecast/#{third_churn_forecast.id}" }

    let(:attributes) { { churn_forecast: 49 } }
    let(:company)    { second_company }
    let(:url)        { api_v1_churn_forecast_url(third_churn_forecast, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, churn_forecast: attributes
      end.not_to change(company.churn_forecast, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated conversion summary' do
      subject { third_churn_forecast.reload }
      its(:churn_forecast) { should == attributes[:churn_forecast] }

      context 'it ignore all atributes except churn_forecast' do
        let!(:second_period)  { create(:period) }
        let(:attributes)      { { churn_forecast: 20, period_id: second_period.id } }

        its(:churn_forecast)  { should == attributes[:churn_forecast] }
        its(:period_id)       { should == period.id }
      end
    end
  end
end
