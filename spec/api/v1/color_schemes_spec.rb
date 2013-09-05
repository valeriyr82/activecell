require 'spec_helper'

describe Api::V1::ColorSchemesController, :api, :branding do
  include_context 'stuff for the API integration specs'

  describe 'GET /api/v1/color_scheme' do
    it_should_have_api_endpoint path: 'color_scheme'

    let(:credentials) { encode_http_auth_credentials(user.email) }
    let(:url) { api_v1_color_scheme_url(format: :json, subdomain: company.subdomain) }

    before do
      company.branding.create_color_scheme
      company.reload
      get_with_http_auth credentials, url
    end

    it { should have_response_status(:success) }

    describe 'returned JSON' do
      subject(:json) { response.body }
      it 'should got existed color scheme of current company' do
        json.should_not be_blank
      end
    end
  end

  describe 'DELETE /api/v1/color_scheme/:id.json' do
    it_should_have_api_endpoint path: 'color_scheme'

    let(:url) { api_v1_color_scheme_url(format: :json, subdomain: company.subdomain) }
    before do
      company.branding.create_color_scheme
      delete_with_http_auth valid_credentials, url
      company.reload
    end

    it { should have_response_status(:no_content) }

    it "should got color scheme with nil" do
      company.branding_color_scheme.should be_nil
    end
  end

  describe 'POST /api/v1/color_scheme' do
    let(:url) { api_v1_color_scheme_url(format: :json, subdomain: company.subdomain) }
    before { post_with_http_auth valid_credentials, url }

    it { should have_response_status(:created) }

    let(:response_hash) { JSON.parse(response.body) }

    context "should got color_scheme with default value" do
      ColorScheme::DEFAULT_COLOR_SCHEME.each do |default|
        it "#{default[0]} with #{default[1]}" do
          response_hash[default[0].to_s].should == default[1]
        end
      end
    end
  end

  describe 'PUT /api/v1/color_scheme.json' do
    before { company.branding.create_color_scheme }

    context "should got color_scheme with new value" do
      let(:url) { api_v1_color_scheme_url(format: :json, subdomain: company.subdomain) }

      ColorScheme::DEFAULT_COLOR_SCHEME.each do |default|
        before do
          color_scheme_params = { default[0] => "#333333" }
          put_with_http_auth valid_credentials, url, color_scheme: color_scheme_params
          company.reload
        end

        it "#{default[0]} with \"#333333\"" do
          company.branding_color_scheme.send(default[0]).should == "#333333"
        end
      end
    end
  end
end
