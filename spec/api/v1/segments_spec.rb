require 'spec_helper'

describe 'API v1 for segments', :api do
  include_context 'stuff for the API integration specs'

  let!(:segment)        { create(:segment, company: first_company, id: '4fdf2a14b0207a25dd000003', name: 'Gold') }
  let!(:second_segment) { create(:segment, company: first_company, id: '17cc67093475061e3d95369d') }
  let(:third_segment)   { first_company.segments.first }
  let(:fourth_segment)  { second_company.segments.first }

  describe 'GET /api/v1/segments.json' do
    it_should_have_api_endpoint path: 'segments'

    let(:url) { api_v1_segments_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [segment, second_segment, third_segment] }
        let(:second_group) { [fourth_segment] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/segments/:id.json' do
    it_should_have_api_endpoint { "segments/#{segment.id}" }

    let(:url) { api_v1_segment_url(segment, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(segment.name).at_path('name') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/segments.json' do
    it_should_have_api_endpoint path: 'segments'

    let(:attributes) { {name: 'Platinum'} }
    let(:url) { api_v1_segments_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, segment: attributes
      end.to change(company.segments, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_segment) { company.segments.last }

    describe 'created segment' do
      subject { created_segment }

      its(:name)    { should == attributes[:name] }
      its(:company) { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the segment' do
        should be_json_eql(created_segment.to_json)
      end
    end
  end

  describe 'PUT /api/v1/segments/:id.json' do
    it_should_have_api_endpoint { "segments/#{second_segment.id}" }

    let(:attributes) { { name: 'Silver' } }
    let(:url)        { api_v1_segment_url(second_segment, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, segment: attributes
      end.not_to change(company.segments, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated segment' do
      subject { second_segment.reload }

      its(:name) { should == attributes[:name] }
    end
  end

  describe 'DELETE /api/v1/segments/:id.json' do
    it_should_have_api_endpoint { "segments/#{second_segment.id}" }

    let(:url) { api_v1_segment_url(second_segment, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.segments, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_segment_url(fourth_segment, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
