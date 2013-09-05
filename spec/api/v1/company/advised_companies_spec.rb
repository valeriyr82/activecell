require 'spec_helper'

describe 'API v1 for advised company affiliations', :advisor, :api do
  include_context 'stuff for the API integration specs'

  let(:advisor_company) do
    company.upgrade_to_advisor!
    AdvisorCompany.find(company.id)
  end

  before do
    advisor_company.become_an_advisor_for(second_company)
    advisor_company.become_an_advisor_for(third_company)
  end

  let(:subdomain) { advisor_company.subdomain }

  describe 'GET /api/v1/company/advised_company_affiliations.json' do
    let(:url) { api_v1_advised_company_affiliations_url(format: :json, subdomain: subdomain) }

    it_should_have_api_endpoint path: 'company/advised_company_affiliations'

    shared_examples_for 'empty results set' do
      describe 'returned JSON' do
        subject { response.body }
        it { should have_json_size(0) }
      end
    end

    context 'for company without advised companies' do
      let!(:other_advisor) { create(:advisor_company) }
      let(:url) { api_v1_advised_company_affiliations_url(format: :json, subdomain: other_advisor.subdomain) }
      before { get_with_http_auth credentials, url }

      it_behaves_like 'an API request with response status', :success
      include_examples 'empty results set'
    end

    context 'for company with several advised companies' do
      let(:url) { api_v1_advised_company_affiliations_url(format: :json, subdomain: advisor_company.subdomain) }

      context 'when an access was granted' do
        before { get_with_http_auth credentials, url }

        it_behaves_like 'an API request with response status', :success

        describe 'returned JSON' do
          subject { response.body }
          it { should have_json_size(2) }

          it 'should include company' do
            should have_json_value(second_company.id.to_s).at_path('0/company/id')
            should have_json_value(second_company.name).at_path('0/company/name')
            should have_json_value(second_company.branding.logo_url).at_path('0/company/logo_url')
          end

          it 'should include advisor_company' do
            should have_json_value(advisor_company.id.to_s).at_path('0/advisor_company/id')
            should have_json_value(advisor_company.name).at_path('0/advisor_company/name')
            should have_json_value(advisor_company.branding.logo_url).at_path('0/advisor_company/logo_url')
          end
        end
      end

      context 'when an access was revoked' do
        before do
          advisor_company.advised_company_affiliations.each do |affiliation|
            affiliation.update_attribute(:has_access, false)
          end

          get_with_http_auth credentials, url
        end

        it_behaves_like 'an API request with response status', :success
        include_examples 'empty results set'
      end
    end
  end

  describe 'PUT /api/v1/company/advised_company_affiliations.json' do
    let(:affiliation) { advisor_company.advised_company_affiliations.first }

    let(:attributes) { { override_branding: false } }
    let(:url) { api_v1_advised_company_affiliation_url(affiliation, format: :json, subdomain: subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, company_affiliation: attributes
      end.not_to change(company.company_affiliations, :count)
      affiliation.reload
    end

    it { should have_response_status(:no_content) }

    describe 'updated affiliation' do
      subject(:updated_affiliation) { affiliation }

      it 'revoke an access' do
        updated_affiliation.override_branding.should be_false
      end
    end
  end

end
