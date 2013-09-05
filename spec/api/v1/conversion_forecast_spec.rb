require 'spec_helper'

describe 'API v1 for conversion forecast', :api do
  include_context 'stuff for the API integration specs'

  let!(:conversion_forecast)        { create(:conversion_forecast, company: first_company, id: '4fdf2a14b0207a25dd000003') }
  let!(:second_conversion_forecast) { create(:conversion_forecast, company: first_company) }

  let!(:period)                     { create(:period) }
  let!(:scenario)                   { create(:scenario, company: second_company) }
  let!(:channel)                    { create(:channel, company: second_company) }
  let!(:stage)                      { create(:stage, company: second_company) }
  let!(:third_conversion_forecast)  { create(:conversion_forecast, company: second_company, id: '17cc67093475061e3d95369d',
                                              conversion_forecast: 72, period: period,
                                              scenario: scenario, stage: stage, channel: channel) }

  describe 'GET /api/v1/conversion_forecast.json' do
    it_should_have_api_endpoint path: 'conversion_forecast'

    let(:url) { api_v1_conversion_forecast_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [conversion_forecast, second_conversion_forecast] }
        let(:second_group) { [third_conversion_forecast] }
      end

      describe 'returned JSON' do
        let(:company) { second_company }
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(third_conversion_forecast.id.to_s).at_path('0/id') }
        it { should have_json_value(third_conversion_forecast.conversion_forecast).at_path('0/conversion_forecast') }
        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(scenario.id.to_s).at_path('0/scenario_id') }
        it { should have_json_value(stage.id.to_s).at_path('0/stage_id') }
        it { should have_json_value(channel.id.to_s).at_path('0/channel_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'PUT /api/v1/conversion_forecast/:id.json' do
    it_should_have_api_endpoint { "conversion_forecast/#{third_conversion_forecast.id}" }

    let(:attributes) { { conversion_forecast: 48 } }
    let(:company)    { second_company }
    let(:url)        { api_v1_conversion_forecast_url(third_conversion_forecast, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, conversion_forecast: attributes
      end.not_to change(company.conversion_forecast, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated conversion summary' do
      subject { third_conversion_forecast.reload }
      its(:conversion_forecast) { should == attributes[:conversion_forecast] }

      context 'it ignore all atributes except conversion_forecast' do
        let!(:second_period)  { create(:period) }
        let(:attributes)      { { conversion_forecast: 20, period_id: second_period.id } }

        its(:conversion_forecast) { should == attributes[:conversion_forecast] }
        its(:period_id)       { should == period.id }
      end
    end
  end
end
