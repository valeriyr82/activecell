require 'spec_helper'

describe 'API v1 for industries', :api do
  include_context 'stuff for the API integration specs'

  let(:suggested_streams)  { ['Stream 1', 'Stream 2', 'Stream 3'] }
  let(:suggested_channels) { ['Channel 1','Channel 2','Channel 3'] }
  let(:suggested_segments) { ['Segment 1','Segment 2','Segment 3'] }
  let(:suggested_stages)   { ['Stage 1','Stage 2','Stage 3'] }

  let!(:industry)        { create(:industry, id: '4fdf2a14b0207a25dd123452',
                                   suggested_streams: suggested_streams,
                                   suggested_channels: suggested_channels,
                                   suggested_segments: suggested_segments,
                                   suggested_stages: suggested_stages) }
  let!(:second_industry) { create(:industry) }
  let!(:third_industry)  { create(:industry) }

  describe 'GET /api/v1/industries.json' do
    it_should_have_api_endpoint path: 'industries'

    let(:url) { api_v1_industries_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }

      it { should have_response_status(:success) }

      it_behaves_like 'a GET :index with items' do
        let(:include_items) { [industry, second_industry, third_industry] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/industries/:id.json' do
    it_should_have_api_endpoint { "industries/#{industry.id}" }

    let(:url) { api_v1_industry_url(industry, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(industry.name).at_path('name') }
      it { should have_json_value(suggested_streams.as_json).at_path('suggested_streams') }
      it { should have_json_value(suggested_channels.as_json).at_path('suggested_channels') }
      it { should have_json_value(suggested_segments.as_json).at_path('suggested_segments') }
      it { should have_json_value(suggested_stages.as_json).at_path('suggested_stages') }
    end
  end
end
