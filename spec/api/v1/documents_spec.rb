require 'spec_helper'

describe 'API v1 for documents', :api do
  include_context 'stuff for the API integration specs'

  let!(:document)        { create(:document, company: first_company, id: '4fdf2a14b0207a25dd000003', response: 'JSON text') }
  let!(:second_document) { create(:document, company: first_company) }
  let!(:third_document)  { create(:document, company: second_company) }

  describe 'GET /api/v1/documents/:id.json' do
    it_should_have_api_endpoint { "documents/#{document.id}" }

    let(:url) { api_v1_document_url(document, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(document.id.to_s).at_path('id') }
      it { should have_json_value(document.response).at_path('response') }
      it { should_not have_json_path('company_id') }
    end
  end
end
