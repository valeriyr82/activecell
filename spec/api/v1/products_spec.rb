require 'spec_helper'

describe 'API v1 for products', :api do
  include_context 'stuff for the API integration specs'

  let!(:revenue_stream)  { create(:revenue_stream, name: 'Professional services') }
  let!(:product)         { create(:product, company: first_company, id: '17cc67093475061e3d95369d',
                                            name: 'Consulting', revenue_stream: revenue_stream) }
  let!(:second_product)  { create(:product, company: first_company, id: '4ffe5b96b0207aff8a0000ec') }
  let!(:third_product)   { create(:product, company: first_company, id: '4fdf2a14b0207a25dd000002') }
  let!(:fourth_product)  { create(:product, company: second_company) }

  describe 'GET /api/v1/products.json' do
    it_should_have_api_endpoint path: 'products'

    let(:url) { api_v1_products_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [product, second_product, third_product] }
        let(:second_group) { [fourth_product] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/products/:id.json' do
    it_should_have_api_endpoint { "products/#{product.id}" }

    let(:url) { api_v1_product_url(product, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(product.name).at_path('name') }
      it { should have_json_value(revenue_stream.as_json).at_path('revenue_stream') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/products.json' do
    it_should_have_api_endpoint path: 'products'

    let(:attributes) { {name: 'Magazine ads', revenue_stream_id: revenue_stream.id} }
    let(:url) { api_v1_products_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, product: attributes
      end.to change(company.products, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_product) { company.products.last }

    describe 'created product' do
      subject { created_product }

      its(:name)           { should == attributes[:name] }
      its(:revenue_stream) { should == revenue_stream }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the product' do
        should be_json_eql(created_product.to_json)
      end
    end
  end

  describe 'PUT /api/v1/products/:id.json' do
    it_should_have_api_endpoint { "products/#{second_product.id}" }

    let(:attributes) { { name: 'Affiliate revenue', revenue_stream_id: revenue_stream.id } }
    let(:url) { api_v1_product_url(second_product, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, product: attributes
      end.not_to change(company.products, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated product' do
      subject { second_product.reload }

      its(:name)           { should == attributes[:name] }
      its(:revenue_stream) { should == revenue_stream }
    end
  end

  describe 'DELETE /api/v1/products/:id.json' do
    it_should_have_api_endpoint { "products/#{third_product.id}" }

    let(:url) { api_v1_product_url(third_product, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.products, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end

end
