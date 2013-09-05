require 'spec_helper'

describe 'API v1 for stages', :api do
  include_context 'stuff for the API integration specs'

  let!(:stage)        { create(:stage, company: first_company, id: '4fdf2a14b0207a25dd000003',
                                name: 'Lead', position: 3, lag_periods: 6) }
  let!(:second_stage) { create(:stage, company: first_company, id: '17cc67093475061e3d95369d',
                                position: 4) }
  let!(:third_stage)  { second_company.stages.first }

  describe 'GET /api/v1/stages.json' do
    it_should_have_api_endpoint path: 'stages'

    let(:url) { api_v1_stages_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [first_company.stages.first, stage, second_stage] }
        let(:second_group) { [third_stage] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/stages/:id.json' do
    it_should_have_api_endpoint { "stages/#{stage.id}" }

    let(:url) { api_v1_stage_url(stage, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(stage.name).at_path('name') }
      it { should have_json_value(stage.position).at_path('position') }
      it { should have_json_value(stage.lag_periods).at_path('lag_periods') }
      it { should_not have_json_path('company_id') }
    end
  end

  describe 'POST /api/v1/stages.json' do
    it_should_have_api_endpoint path: 'stages'

    let(:attributes) { {name: 'New Stage', lag_periods: 4, position: 7} }
    let(:url) { api_v1_stages_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, stage: attributes
      end.to change(company.stages, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_stage) { company.stages.last }

    describe 'created stage' do
      subject { created_stage }

      its(:name)        { should == attributes[:name] }
      its(:lag_periods) { should == attributes[:lag_periods] }
      its(:position)    { should == attributes[:position] }
      its(:company)     { should == first_company }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the stage' do
        should be_json_eql(created_stage.to_json)
      end
    end
  end

  describe 'PUT /api/v1/stages/:id.json' do
    it_should_have_api_endpoint { "stages/#{second_stage.id}" }

    let(:attributes) { { name: 'Prospect', lag_periods: 12, position: 9 } }
    let(:url)        { api_v1_stage_url(second_stage, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, stage: attributes
      end.not_to change(company.stages, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated stage' do
      subject { second_stage.reload }

      its(:name)        { should == attributes[:name] }
      its(:lag_periods) { should == attributes[:lag_periods] }
      its(:position)    { should == attributes[:position] }
    end
  end

  describe 'DELETE /api/v1/stages/:id.json' do
    it_should_have_api_endpoint { "stages/#{second_stage.id}" }

    let(:url) { api_v1_stage_url(second_stage, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(first_company.stages, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_stage_url(third_stage, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
