require 'spec_helper'

describe 'API v1 for customers', :api do
  include_context 'stuff for the API integration specs'

  let!(:channel)         { create(:channel) }
  let!(:segment)         { create(:segment) }
  let!(:customer)        { create(:customer, company: first_company, id: '4fdf2a14b0207a25dd000003',
                                             name: 'Lucky Strike', channel: channel, segment: segment) }
  let!(:second_customer) { create(:customer, company: first_company, id: '17cc67093475061e3d95369d') }
  let!(:third_customer)  { create(:customer, company: second_company) }

  describe 'GET /api/v1/customers.json' do
    it_should_have_api_endpoint path: 'customers'

    let(:url) { api_v1_customers_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [customer, second_customer] }
        let(:second_group) { [third_customer] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/customers/:id.json' do
    it_should_have_api_endpoint { "customers/#{customer.id}" }

    let(:url) { api_v1_customer_url(customer, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(customer.name).at_path('name') }
      it { should have_json_value(channel.as_json).at_path('channel') }
      it { should have_json_value(segment.as_json).at_path('segment') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/customers.json' do
    it_should_have_api_endpoint path: 'customers'

    let(:attributes) { {name: 'Madison Avenue Properties', channel_id: channel.id, segment_id: segment.id} }
    let(:url) { api_v1_customers_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, customer: attributes
      end.to change(company.customers, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_customer) { company.customers.last }

    describe 'created customer' do
      subject { created_customer }

      its(:name)    { should == attributes[:name] }
      its(:company) { should == first_company }
      its(:channel) { should == channel }
      its(:segment) { should == segment }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the customer' do
        should be_json_eql(created_customer.to_json)
      end
    end
  end

  describe 'PUT /api/v1/customers/:id.json' do
    it_should_have_api_endpoint { "customers/#{second_customer.id}" }

    let(:attributes) { { name: 'Unilever', channel_id: channel.id, segment_id: segment.id } }
    let(:url)        { api_v1_customer_url(second_customer, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, customer: attributes
      end.not_to change(company.customers, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated customer' do
      subject { second_customer.reload }

      its(:name)    { should == attributes[:name] }
      its(:channel) { should == channel }
      its(:segment) { should == segment }
    end
  end

  describe 'DELETE /api/v1/customers/:id.json' do
    it_should_have_api_endpoint { "customers/#{second_customer.id}" }

    let(:url) { api_v1_customer_url(second_customer, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.customers, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
