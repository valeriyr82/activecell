require 'spec_helper'

describe 'API v1 for categories', :api do
  include_context 'stuff for the API integration specs'

  let!(:category)        { create(:category, company: first_company, id: '4fdf2a14b0207a25dd000003', name: 'Rent') }
  let!(:second_category) { create(:category, company: first_company, id: '17cc67093475061e3d95369d') }
  let(:third_category)   { first_company.categories.first }
  let(:fourth_category)  { second_company.categories.first }

  describe 'GET /api/v1/categories.json' do
    it_should_have_api_endpoint path: 'categories'

    let(:url) { api_v1_categories_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [category, second_category, third_category] }
        let(:second_group) { [fourth_category] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/categories/:id.json' do
    it_should_have_api_endpoint { "categories/#{category.id}" }

    let(:url) { api_v1_category_url(category, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(category.name).at_path('name') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/categories.json' do
    it_should_have_api_endpoint path: 'categories'

    let(:attributes) { {name: 'Media buys'} }
    let(:url) { api_v1_categories_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, category: attributes
      end.to change(company.categories, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_category) { company.categories.last }

    describe 'created category' do
      subject { created_category }

      its(:name)    { should == attributes[:name] }
      its(:company) { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the category' do
        should be_json_eql(created_category.to_json)
      end
    end
  end

  describe 'PUT /api/v1/categories/:id.json' do
    it_should_have_api_endpoint { "categories/#{second_category.id}" }

    let(:attributes) { { name: 'Media buys' } }
    let(:url)        { api_v1_category_url(second_category, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, category: attributes
      end.not_to change(company.categories, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated category' do
      subject { second_category.reload }

      its(:name) { should == attributes[:name] }
    end
  end

  describe 'DELETE /api/v1/categories/:id.json' do
    it_should_have_api_endpoint { "categories/#{category.id}" }

    let(:url) { api_v1_category_url(category, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.categories, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_category_url(fourth_category, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
