require 'spec_helper'

describe 'API v1 for channels', :api do
  include_context 'stuff for the API integration specs'

  let!(:channel)        { create(:channel, company: first_company, id: '4fdf2', name: 'Content marketing', commission: 0.2,
                                           channel_segment_mix: [{distribution: 1.0, segment_id: segment.id}]) }
  let!(:second_channel) { create(:channel, company: first_company, id: '17cc6') }
  let(:third_channel)   { first_company.channels.first }
  let(:fourth_channel)  { second_company.channels.first }
  let(:segment)         { create(:segment) }
  let(:second_segment)  { create(:segment) }

  describe 'GET /api/v1/channels.json' do
    it_should_have_api_endpoint path: 'channels'

    let(:url) { api_v1_channels_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success

      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [channel, second_channel, third_channel] }
        let(:second_group) { [fourth_channel] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/channels/:id.json' do
    it_should_have_api_endpoint { "channels/#{channel.id}" }

    let(:url) { api_v1_channel_url(channel, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value(channel.name).at_path('name') }
      it { should have_json_value(channel.commission).at_path('commission') }
      it { should_not have_json_path('company_id') }

      context 'includes channel segment mix' do
        it { should_not have_json_path('channel_segment_mix/0/id') }
        it { should have_json_value(1.0).at_path('channel_segment_mix/0/distribution') }
        it { should have_json_value(segment.id.to_s).at_path('channel_segment_mix/0/segment_id') }
      end
    end
  end

  describe 'POST /api/v1/channels.json' do
    it_should_have_api_endpoint path: 'channels'

    let(:segment_mixes) { [{segment_id: segment.id, distribution: 0.8}, {segment_id: second_segment.id, distribution: 0.2}] }
    let(:attributes)    { { name: 'Affiliate sales', commission: 0.1, channel_segment_mix: segment_mixes } }
    let(:url) { api_v1_channels_url(format: :json, subdomain: company.subdomain) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, channel: attributes
      end.to change(company.channels, :count).by(1)
    end

    it_behaves_like 'an API request with response status', :created
    let(:created_channel) { company.channels.last }

    describe 'created channel' do
      subject { created_channel }

      its(:name)       { should == attributes[:name] }
      its(:commission) { should == attributes[:commission] }
      its(:company)    { should == first_company }

      context "create channel_segment_mix" do
        let(:first_created_csmix)  { subject.channel_segment_mix.first }
        let(:second_created_csmix) { subject.channel_segment_mix.last }

        it "contains distribution" do
          first_created_csmix.distribution.should == segment_mixes[0][:distribution]
          second_created_csmix.distribution.should == segment_mixes[1][:distribution]
        end

        it "contains segment" do
          first_created_csmix.segment.should == segment
          second_created_csmix.segment.should == second_segment
        end
      end
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the channel' do
        should be_json_eql(created_channel.to_json)
      end
    end
  end

  describe 'PUT /api/v1/channels/:id.json' do
    it_should_have_api_endpoint { "channels/#{second_channel.id}" }

    let(:attributes) { { name: "Winston's Cigars", commission: 0.25,
                         channel_segment_mix: [{segment_id: segment.id, distribution: 1}] } }
    let(:url)        { api_v1_channel_url(second_channel, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, channel: attributes
      end.not_to change(company.channels, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated channel' do
      subject { second_channel.reload }

      its(:name)       { should == attributes[:name] }
      its(:commission) { should == attributes[:commission] }

      it 'updates channel_segment_mix' do
        first_updated_csmix = subject.channel_segment_mix.first
        first_updated_csmix.distribution.should == 1
      end

      context 'constraint that sum adds to 100%' do
        let(:csmix) { [{segment_id: segment.id, distribution: 0.9}, {segment_id: segment.id, distribution: 0.2}] }
        let(:attributes) { { name: "Winston's Cigars", commission: 0.25, channel_segment_mix: csmix } }

        it_behaves_like 'an API request with response status', :unprocessable_entity
      end
    end
  end

  describe 'DELETE /api/v1/channels/:id.json' do
    it_should_have_api_endpoint { "channels/#{second_channel.id}" }

    let(:url) { api_v1_channel_url(second_channel, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.channels, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
    it_behaves_like 'confirm that at least 1 record exists' do
      let(:second_url) { api_v1_channel_url(fourth_channel, format: :json, subdomain: second_company.subdomain) }
    end
  end
end
