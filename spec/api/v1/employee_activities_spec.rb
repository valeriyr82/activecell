require 'spec_helper'

describe 'API v1 for employee activities', :api do
  include_context 'stuff for the API integration specs'

  let!(:employee_activity)        { create(:employee_activity, id: '4fdf2a14b0207a25dd000002') }
  let!(:second_employee_activity) { create(:employee_activity) }
  let!(:third_employee_activity)  { create(:employee_activity) }

  describe 'GET /api/v1/employee_activity.json' do
    it_should_have_api_endpoint path: 'employee_activities'

    let(:url) { api_v1_employee_activities_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'a GET :index with items' do
        let(:include_items) { [employee_activity, second_employee_activity, third_employee_activity] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/employee_activities/:id.json' do
    it_should_have_api_endpoint { "employee_activities/#{employee_activity.id}" }

    let(:url) { api_v1_employee_activity_url(employee_activity, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the employee activity' do
        should be_json_eql(employee_activity.to_json)
      end
    end
  end

end
