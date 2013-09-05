require 'spec_helper'

describe 'API v1 for scenarios', :api do
  include_context 'stuff for the API integration specs'

  let!(:scenario)        { create(:scenario, company: first_company, id: '17cc67093475061e3d95369d') }
  let!(:second_scenario) { create(:scenario, company: first_company) }
  let!(:third_scenario)  { first_company.scenarios.first }
  let!(:fourth_scenario) { second_company.scenarios.first }

  describe 'GET /api/v1/scenarios.json' do
    it_should_have_api_endpoint path: 'scenarios'

    let(:url) { api_v1_scenarios_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }

      it { should have_response_status(:success) }

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [scenario, second_scenario, third_scenario] }
        let(:second_group) { [fourth_scenario] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/scenarios/:id.json' do
    it_should_have_api_endpoint { "scenarios/#{scenario.id}" }

    let(:url) { api_v1_scenario_url(scenario, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it { should have_response_status(:success) }
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the scenario' do
        should be_json_eql(scenario.to_json)
      end
    end

    describe 'for the other company' do
      let(:company) { second_company }

      it { should have_response_status(:not_found) }

      describe 'returned JSON' do
        subject { response.body }

        it { should have_json_path('error') }
        it { should have_json_type(String).at_path('error') }
      end
    end
  end

  describe 'POST /api/v1/scenarios.json' do
    it_should_have_api_endpoint path: 'scenarios'

    let(:attributes) { attributes_for(:scenario) }
    let(:url) { api_v1_scenarios_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, scenario: attributes
      end.to change(company.scenarios, :count).by(1)
    end

    let(:created_scenario) { Scenario.last }

    it { should have_response_status(:created) }

    describe 'created scenario' do
      subject { created_scenario }

      its(:name)    { should == attributes[:name] }
      its(:company) { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the scenario' do
        should be_json_eql(created_scenario.to_json)
      end
    end
  end

  describe 'PUT /api/v1/scenarios/:id.json' do
    it_should_have_api_endpoint { "scenarios/#{scenario.id}" }

    let(:attributes) { { name: 'New scenario name' } }
    let(:url) { api_v1_scenario_url(scenario, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, scenario: attributes
      end.not_to change(company.scenarios, :count)
    end

    let(:updated_scenario) { scenario.reload }

    it { should have_response_status(:no_content) }

    describe 'updated scenario' do
      subject { updated_scenario }
      its(:name) { should == attributes[:name] }
    end
  end

  describe 'DELETE /api/v1/scenarios/:id.json' do
    it_should_have_api_endpoint { "scenarios/#{scenario.id}" }

    let(:url) { api_v1_scenario_url(scenario, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.scenarios, :count).by(-1)
    end

    it { should have_response_status(:no_content) }
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_scenario_url(fourth_scenario, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
