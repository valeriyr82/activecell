require 'spec_helper'

describe 'API v1 for vendors', :api do
  include_context 'stuff for the API integration specs'

  let!(:vendor)        { create(:vendor, company: first_company, id: '4fdf2a14b0207a25dd000003', name: 'Big Media Co.') }
  let!(:second_vendor) { create(:vendor, company: first_company, id: '17cc67093475061e3d95369d') }
  let!(:third_vendor)  { create(:vendor, company: second_company) }

  describe 'GET /api/v1/vendors.json' do
    it_should_have_api_endpoint path: 'vendors'

    let(:url) { api_v1_vendors_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [vendor, second_vendor] }
        let(:second_group) { [third_vendor] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/vendors/:id.json' do
    it_should_have_api_endpoint { "vendors/#{vendor.id}" }

    let(:url) { api_v1_vendor_url(vendor, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value('Big Media Co.').at_path('name') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/vendors.json' do
    it_should_have_api_endpoint path: 'vendors'

    let(:attributes) { {name: 'Madison Avenue Properties'} }
    let(:url) { api_v1_vendors_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, vendor: attributes
      end.to change(company.vendors, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_vendor) { company.vendors.last }

    describe 'created vendor' do
      subject { created_vendor }

      its(:name)    { should == attributes[:name] }
      its(:company) { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the vendor' do
        should be_json_eql(created_vendor.to_json)
      end
    end
  end

  describe 'PUT /api/v1/vendors/:id.json' do
    it_should_have_api_endpoint { "vendors/#{second_vendor.id}" }

    let(:attributes) { { name: "Winston's Cigars" } }
    let(:url)        { api_v1_vendor_url(second_vendor, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, vendor: attributes
      end.not_to change(company.vendors, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated vendor' do
      subject { second_vendor.reload }

      its(:name) { should == attributes[:name] }
    end
  end

  describe 'DELETE /api/v1/vendors/:id.json' do
    it_should_have_api_endpoint { "vendors/#{second_vendor.id}" }

    let(:url) { api_v1_vendor_url(second_vendor, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.vendors, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
