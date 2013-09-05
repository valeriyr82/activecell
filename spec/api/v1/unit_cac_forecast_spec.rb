require 'spec_helper'

describe 'API v1 for unit customer acquisition cost forecast', :api do
  include_context 'stuff for the API integration specs'

  let!(:unit_cac_forecast)        { create(:unit_cac_forecast, company: first_company) }
  let!(:second_unit_cac_forecast) { create(:unit_cac_forecast, company: first_company) }

  let!(:scenario)                 { create(:scenario, company: second_company) }
  let!(:category)                 { create(:category, company: second_company) }
  let!(:channel)                  { create(:channel, company: second_company) }
  let!(:third_unit_cac_forecast)  { create(:unit_cac_forecast, company: second_company, id: '17cc67093475061e3d95369d',
                                            unit_cac_forecast: 9999, scenario: scenario, category: category, channel: channel) }

  describe 'GET /api/v1/unit_cac_forecast.json' do
    it_should_have_api_endpoint path: 'unit_cac_forecast'

    let(:url) { api_v1_unit_cac_forecast_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [unit_cac_forecast, second_unit_cac_forecast] }
        let(:second_group) { [third_unit_cac_forecast] }
      end

      describe 'returned JSON' do
        let(:company) { second_company }
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(third_unit_cac_forecast.id.to_s).at_path('0/id') }
        it { should have_json_value(scenario.id.to_s).at_path('0/scenario_id') }
        it { should have_json_value(category.id.to_s).at_path('0/category_id') }
        it { should have_json_value(channel.id.to_s).at_path('0/channel_id') }
        it { should have_json_value(third_unit_cac_forecast.unit_cac_forecast).at_path('0/unit_cac_forecast') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'PUT /api/v1/unit_cac_forecast/:id.json' do
    it_should_have_api_endpoint { "unit_cac_forecast/#{third_unit_cac_forecast.id}" }

    let(:attributes) { { unit_cac_forecast: 49 } }
    let(:company)    { second_company }
    let(:url)        { api_v1_unit_cac_forecast_url(third_unit_cac_forecast, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, unit_cac_forecast: attributes
      end.not_to change(company.unit_cac_forecast, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated conversion summary' do
      subject { third_unit_cac_forecast.reload }
      its(:unit_cac_forecast) { should == attributes[:unit_cac_forecast] }

      context 'it ignore all atributes except unit_cac_forecast' do
        let!(:second_channel)   { create(:channel, company: second_company) }
        let(:attributes)        { { unit_cac_forecast: 20, channel_id: second_channel.id } }

        its(:unit_cac_forecast) { should == attributes[:unit_cac_forecast] }
        its(:channel_id)        { should == channel.id }
      end
    end
  end
end
