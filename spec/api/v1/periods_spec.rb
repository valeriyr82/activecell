require 'spec_helper'

describe 'API v1 for periods', :api do
  include_context 'stuff for the API integration specs'

  let!(:first_period)  { create(:period) }
  let!(:second_period) { create(:period) }
  let!(:third_period)  { create(:period) }
  let!(:fourth_period) { create(:period) }

  describe 'GET /api/v1/periods.json' do
    it_should_have_api_endpoint path: 'periods'

    let(:url) { api_v1_periods_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }

      it { should have_response_status(:success) }

      it_behaves_like 'a GET :index with items' do
        let(:include_items) { [first_period, second_period, third_period, fourth_period] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end
end
