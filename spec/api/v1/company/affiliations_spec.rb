require 'spec_helper'

describe 'API v1 for company affiliations', :api, :advisor do
  include_context 'stuff for the API integration specs'

  describe 'GET /api/v1/company/affiliations.json' do
    it_should_have_api_endpoint path: 'company/affiliations'

    let(:url) { api_v1_company_affiliations_url(format: :json, subdomain: company.subdomain) }

    context 'for company with several affiliations' do
      let!(:first_user) { create(:user) }
      let!(:second_user) { create(:user) }
      let!(:first_advisor_company) { create(:advisor_company) }
      let!(:second_advisor_company) { create(:advisor_company) }

      before do
        company.invite_user(first_user)
        company.invite_user(second_user)
        company.invite_advisor(first_advisor_company)
        company.invite_advisor(second_advisor_company)

        get_with_http_auth credentials, url
      end

      it_behaves_like 'an API request with response status', :success

      describe 'returned JSON' do
        subject { response.body }
        it { should have_json_size(5) }

        it 'should include all user affiliations' do
          [user, first_user, second_user].each do |u|
            should include_json(u.company_affiliations.first.to_json)
          end
        end

        it 'should include all advisor company affiliations' do
          [first_advisor_company, second_advisor_company].each do |c|
            should include_json(c.advised_company_affiliations.first.to_json)
          end
        end
      end
    end
  end

  describe 'PUT /api/v1/company/affiliations.json' do
    let(:affiliation) { company.company_affiliations.first }

    let(:attributes) { { has_access: false } }
    let(:url) { api_v1_company_affiliation_url(affiliation, format: :json, subdomain: company.subdomain) }

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
        updated_affiliation.has_access.should be_false
      end
    end
  end

end
