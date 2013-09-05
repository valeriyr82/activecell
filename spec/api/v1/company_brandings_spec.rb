require 'spec_helper'

describe 'API v1 for company brandings', :api, :branding do
  include_context 'stuff for the API integration specs'

  describe 'PUT /api/v1/company_branding.json' do
    let(:url) { api_v1_company_branding_url(format: :json, subdomain: company.subdomain) }
    it_should_have_api_endpoint path: "company_branding"

    let(:file_name) { "sample_logo.png" }
    let(:file) { fixture_file_upload("#{Rails.root}/spec/fixtures/#{file_name}", "image/png") }

    let!(:other_country) { create(:country) }
    let(:attributes) { { logo: file } }

    context 'on success' do
      before do
        Paperclip::Attachment.any_instance.should_receive(:save).and_return(true)
        expect do
          put_with_http_auth valid_credentials, url, company_branding: attributes
        end.not_to change(Company, :count)
      end

      it { should have_response_status(:no_content) }
    end

    context 'when logo upload fails' do
      before do
        expect do
          put_with_http_auth valid_credentials, url, company_branding: attributes
        end.not_to change(Company, :count)
      end

      let(:file) { fixture_file_upload("#{Rails.root}/spec/spec_helper.rb", "application/x-ruby") }

      it { should have_response_status(:unprocessable_entity) }

      describe 'response' do
        subject { response.body }

        it "should receive response with errors" do
          should have_json_size(2).at_path('errors')
        end

        it "should receive response with error message of logo" do
          should have_json_value(["must be in 'png/jpg/jpeg/gif' format"]).at_path('errors/logo_content_type')
        end
      end
    end
  end

end
