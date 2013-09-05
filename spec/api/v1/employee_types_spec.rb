require 'spec_helper'

describe 'API v1 for employee types', :api do
  include_context 'stuff for the API integration specs'

  let!(:employee_type)        {create(:employee_type, company: first_company, id: '4fdf2a14b0207a25dd000003', name: 'Partner')}
  let!(:second_employee_type) {create(:employee_type, company: first_company, id: '17cc67093475061e3d95369d')}
  let(:third_employee_type)   { first_company.employee_types.first }
  let(:fourth_employee_type)  { second_company.employee_types.first }

  describe 'GET /api/v1/employee_types.json' do
    it_should_have_api_endpoint path: 'employee_types'

    let(:url) { api_v1_employee_types_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [employee_type, second_employee_type, third_employee_type] }
        let(:second_group) { [fourth_employee_type] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/employee_types/:id.json' do
    it_should_have_api_endpoint { "employee_types/#{employee_type.id}" }

    let(:url) { api_v1_employee_type_url(employee_type, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(employee_type.name).at_path('name') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/employee_types.json' do
    it_should_have_api_endpoint path: 'employee_types'

    let(:attributes) { {name: 'Assistant'} }
    let(:url) { api_v1_employee_types_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, employee_type: attributes
      end.to change(company.employee_types, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_employee_type) { company.employee_types.last }

    describe 'created employee type' do
      subject { created_employee_type }

      its(:name)    { should == attributes[:name] }
      its(:company) { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the category' do
        should be_json_eql(created_employee_type.to_json)
      end
    end
  end

  describe 'PUT /api/v1/employee_types/:id.json' do
    it_should_have_api_endpoint { "employee_types/#{second_employee_type.id}" }

    let(:attributes) { { name: 'Account Executive' } }
    let(:url)        { api_v1_employee_type_url(second_employee_type, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, employee_type: attributes
      end.not_to change(company.employee_types, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated second employee type' do
      subject { second_employee_type.reload }

      its(:name) { should == attributes[:name] }
    end
  end

  describe 'DELETE /api/v1/employee_types/:id.json' do
    it_should_have_api_endpoint { "employee_types/#{employee_type.id}" }

    let(:url) { api_v1_employee_type_url(employee_type, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.employee_types, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_employee_type_url(fourth_employee_type, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
