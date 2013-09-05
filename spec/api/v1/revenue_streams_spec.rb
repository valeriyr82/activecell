require 'spec_helper'

describe 'API v1 for revenue streams', :api do
  include_context 'stuff for the API integration specs'

  let!(:revenue_stream) { create(:revenue_stream, company: first_company, id: '4fdf2a14b0207a25', name: 'Media purchases') }
  let(:second_revenue_stream) { first_company.revenue_streams.first }
  let(:third_revenue_stream)  { second_company.revenue_streams.first }

  describe 'GET /api/v1/revenue_streams.json' do
    it_should_have_api_endpoint path: 'revenue_streams'

    let(:url) { api_v1_revenue_streams_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }

      it { should have_response_status(:success) }

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [revenue_stream, second_revenue_stream] }
        let(:second_group) { [third_revenue_stream] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/revenue_streams/:id.json' do
    it_should_have_api_endpoint { "revenue_streams/#{revenue_stream.id}" }

    let(:url) { api_v1_revenue_stream_url(revenue_stream, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it { should have_response_status(:success) }
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value('Media purchases').at_path('name') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/revenue_streams.json' do
    it_should_have_api_endpoint path: 'revenue_streams'

    let(:attributes) { attributes_for(:revenue_stream) }
    let(:url) { api_v1_revenue_streams_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, revenue_stream: attributes
      end.to change(company.revenue_streams, :count).by(1)
    end

    it { should have_response_status(:created) }
    let(:created_revenue_stream) { RevenueStream.last }

    describe 'created revenue_stream' do
      subject { created_revenue_stream }

      its(:name) { should == attributes[:name] }
      its(:company) { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the revenue_stream' do
        should be_json_eql(created_revenue_stream.to_json)
      end
    end
  end

  describe 'PUT /api/v1/revenue_streams/:id.json' do
    it_should_have_api_endpoint { "revenue_streams/#{revenue_stream.id}" }

    let(:attributes) { { name: 'New revenue_stream name' } }
    let(:url) { api_v1_revenue_stream_url(revenue_stream, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, revenue_stream: attributes
      end.not_to change(company.revenue_streams, :count)
    end

    it { should have_response_status(:no_content) }

    describe 'updated revenue_stream' do
      let(:updated_revenue_stream) { revenue_stream.reload }
      subject { revenue_stream.reload }

      its(:name) { should == attributes[:name] }
    end
  end

  describe 'DELETE /api/v1/revenue_streams/:id.json' do
    it_should_have_api_endpoint { "revenue_streams/#{revenue_stream.id}" }

    let(:url) { api_v1_revenue_stream_url(revenue_stream, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.revenue_streams, :count).by(-1)
    end

    it { should have_response_status(:no_content) }
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_revenue_stream_url(third_revenue_stream, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
