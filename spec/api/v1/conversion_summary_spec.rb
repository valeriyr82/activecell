require 'spec_helper'

describe 'API v1 for conversion summary', :api do
  include_context 'stuff for the API integration specs'

  let!(:conversion_summary)        { create(:conversion_summary, company: first_company, id: '4fdf2a14b0207a25dd000003') }
  let!(:second_conversion_summary) { create(:conversion_summary, company: first_company) }

  let!(:period)                    { create(:period) }
  let!(:stage)                     { create(:stage, company: second_company) }
  let!(:channel)                   { create(:channel, company: second_company) }
  let!(:third_conversion_summary)  { create(:conversion_summary, company: second_company, customer_volume: 10,
                                             id: '17cc67093475061e3d95369d', period: period, stage: stage, channel: channel) }

  describe 'GET /api/v1/conversion_summary.json' do
    it_should_have_api_endpoint path: 'conversion_summary'

    let(:url) { api_v1_conversion_summary_index_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [conversion_summary, second_conversion_summary] }
        let(:second_group) { [third_conversion_summary] }
      end

      describe 'returned JSON' do
        let(:company) { second_company }
        subject { response.body }

        it { should_not have_json_path('0/company_id') }
        it { should have_json_value(third_conversion_summary.id.to_s).at_path('0/id') }
        it { should have_json_value(third_conversion_summary.customer_volume).at_path('0/customer_volume') }
        it { should have_json_value(period.id.to_s).at_path('0/period_id') }
        it { should have_json_value(stage.id.to_s).at_path('0/stage_id') }
        it { should have_json_value(channel.id.to_s).at_path('0/channel_id') }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'PUT /api/v1/conversion_summary/:id.json' do
    it_should_have_api_endpoint { "conversion_summary/#{third_conversion_summary.id}" }

    let(:attributes) { { customer_volume: 49 } }
    let(:company)    { second_company }
    let(:url)        { api_v1_conversion_summary_url(third_conversion_summary, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, conversion_summary: attributes
      end.not_to change(company.conversion_summary, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated conversion summary' do
      subject { third_conversion_summary.reload }
      its(:customer_volume) { should == attributes[:customer_volume] }

      context 'it ignore all attributes except customer_volume' do
        let!(:second_period)  { create(:period) }
        let!(:second_stage)   { create(:stage, company: company) }
        let!(:second_channel) { create(:channel, company: company) }

        let(:attributes)      { { customer_volume: 20, period_id: second_period.id, stage_id: second_stage.id,
                                  channel_id: second_channel.id, company_id: first_company.id } }

        its(:customer_volume) { should == attributes[:customer_volume] }
        its(:period_id)       { should == period.id }
        its(:stage_id)        { should == stage.id }
        its(:channel_id)      { should == channel.id }
        its(:company_id)      { should == company.id }
      end
    end
  end
end
