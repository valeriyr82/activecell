require 'spec_helper'

describe 'API v1 for unit revenue forecast', :api do
  include_context 'stuff for the API integration specs'

  let!(:unit_rev_forecast)        { create(:unit_rev_forecast, company: first_company) }
  let!(:second_unit_rev_forecast) { create(:unit_rev_forecast, company: first_company) }

  let!(:scenario)                 { create(:scenario, company: second_company) }
  let!(:revenue_stream)           { create(:revenue_stream, company: second_company) }
  let!(:segment)                  { create(:segment, company: second_company) }
  let!(:third_unit_rev_forecast)  { create(:unit_rev_forecast, company: second_company, id: '17cc67093475061e3d95369d',
                                            unit_rev_forecast: 8999, scenario: scenario,
                                            revenue_stream: revenue_stream, segment: segment) }

  describe 'GET /api/v1/unit_rev_forecast.json' do
    it_should_have_api_endpoint path: 'unit_rev_forecast'

    let(:url) { api_v1_unit_rev_forecast_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [unit_rev_forecast, second_unit_rev_forecast] }
        let(:second_group) { [third_unit_rev_forecast] }
      end

      describe 'returned JSON' do
        let(:company) { second_company }
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(third_unit_rev_forecast.id.to_s).at_path('0/id') }
        it { should have_json_value(scenario.id.to_s).at_path('0/scenario_id') }
        it { should have_json_value(revenue_stream.id.to_s).at_path('0/revenue_stream_id') }
        it { should have_json_value(segment.id.to_s).at_path('0/segment_id') }
        it { should have_json_value(third_unit_rev_forecast.unit_rev_forecast).at_path('0/unit_rev_forecast') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'PUT /api/v1/unit_rev_forecast/:id.json' do
    it_should_have_api_endpoint { "unit_rev_forecast/#{third_unit_rev_forecast.id}" }

    let(:attributes) { { unit_rev_forecast: 16 } }
    let(:company)    { second_company }
    let(:url)        { api_v1_unit_rev_forecast_url(third_unit_rev_forecast, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, unit_rev_forecast: attributes
      end.not_to change(company.unit_rev_forecast, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated conversion summary' do
      subject { third_unit_rev_forecast.reload }
      its(:unit_rev_forecast) { should == attributes[:unit_rev_forecast] }

      context 'it ignore all atributes except unit_rev_forecast' do
        let!(:second_segment)   { create(:segment, company: second_company) }
        let(:attributes)        { { unit_rev_forecast: 80, segment_id: second_segment.id } }

        its(:unit_rev_forecast) { should == attributes[:unit_rev_forecast] }
        its(:segment_id)        { should == segment.id }
      end
    end
  end
end
