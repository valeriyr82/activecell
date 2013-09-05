require 'spec_helper'

describe 'API v1 for countries', :api do
  include_context 'stuff for the API integration specs'

  let!(:first_country)  { create(:country) }
  let!(:second_country) { create(:country) }

  describe 'GET /api/v1/countries.json' do
    it_should_have_api_endpoint path: 'countries'

    let(:url) { api_v1_countries_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }

      it { should have_response_status(:success) }

      it_behaves_like 'a GET :index with items' do
        let(:include_items) { [first_country, second_country] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end
end
