require 'spec_helper'

describe 'API v1 for employees', :api do
  include_context 'stuff for the API integration specs'

  let!(:employee_type)   {create(:employee_type, company: first_company)}
  let!(:employee)        {create(:employee, company: first_company, id: '4fdf2a14b0207a25dd000003',
                                            employee_type: employee_type, name: 'Pete Campbell')}
  let!(:second_employee) {create(:employee, company: first_company, id: '17cc67093475061e3d95369d')}
  let!(:third_employee)  {create(:employee, company: second_company)}

  describe 'GET /api/v1/employees.json' do
    it_should_have_api_endpoint path: 'employees'

    let(:url) { api_v1_employees_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [employee, second_employee] }
        let(:second_group) { [third_employee] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/employees/:id.json' do
    it_should_have_api_endpoint { "employees/#{employee.id}" }

    let(:url) { api_v1_employee_url(employee, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(employee.name).at_path('name') }
      it { should have_json_value(employee_type.as_json).at_path('employee_type') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/employees.json' do
    it_should_have_api_endpoint path: 'employees'

    let(:attributes) { {name: 'Roger Sterling', employee_type_id: employee_type.id} }
    let(:url) { api_v1_employees_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, employee: attributes
      end.to change(company.employees, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_employee) { company.employees.last }

    describe 'created employee' do
      subject { created_employee }

      its(:name)          { should == attributes[:name] }
      its(:employee_type) { should == employee_type }
      its(:company)       { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the category' do
        should be_json_eql(created_employee.to_json)
      end
    end
  end

  describe 'PUT /api/v1/employees/:id.json' do
    it_should_have_api_endpoint { "employees/#{second_employee.id}" }

    let(:attributes) { { name: 'Roger Sterling', employee_type_id: employee_type.id } }
    let(:url)        { api_v1_employee_url(second_employee, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, employee: attributes
      end.not_to change(company.employees, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated second employee type' do
      subject { second_employee.reload }

      its(:name) { should == attributes[:name] }
      its(:employee_type) { should == employee_type }
    end
  end

  describe 'DELETE /api/v1/employees/:id.json' do
    it_should_have_api_endpoint { "employees/#{employee.id}" }

    let(:url) { api_v1_employee_url(employee, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.employees, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
