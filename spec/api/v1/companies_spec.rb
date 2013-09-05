require 'spec_helper'

describe 'API v1 for companies', :api do
  include_context 'stuff for the API integration specs'

  describe 'GET /api/v1/companies.json' do
    it_should_have_api_endpoint path: "companies", subdomain: 'www'

    let(:url) { api_v1_companies_url(format: :json) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      context 'for user with two companies' do
        let(:credentials) { encode_http_auth_credentials(user.email) }

        it { should have_response_status(:success) }

        describe 'returned JSON' do
          subject { response.body }

          it { should have_json_size(2) }
          it 'should include all current user companies' do
            should include_json(first_company.to_json)
            should include_json(second_company.to_json)
            should_not include_json(third_company.to_json)
          end
        end
      end

      context 'for user with one company' do
        let(:credentials) { encode_http_auth_credentials(other_user.email) }

        it { should have_response_status(:success) }

        describe 'returned JSON' do
          subject { response.body }

          it { should have_json_size(1) }
          it 'should include all current user companies' do
            should_not include_json(first_company.to_json)
            should_not include_json(second_company.to_json)
            should include_json(third_company.to_json)
          end
        end
      end
    end

    context 'with invalid credentials' do
      let(:credentials) { encode_http_auth_credentials(user.email, 'invalid password') }
      it_behaves_like 'an API request with invalid basic http credentials'
    end
  end

  describe 'GET /api/v1/companies/:id.json' do
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}" }

    let(:url) { api_v1_company_url(first_company, format: :json) }
    before { get_with_http_auth valid_credentials, url }

    it { should have_response_status(:success) }

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value('Address line 1').at_path('address_1') }
      it { should have_json_value('Address line 2').at_path('address_2') }
      it { should have_json_value('1234').at_path('postal_code') }
      it { should have_json_value(company.url).at_path('url') }

      it 'should include the company' do
        should be_json_eql(first_company.to_json)
      end
    end
  end

  describe 'POST /api/v1/companies.json' do
    it_should_have_api_endpoint path: 'companies', subdomain: 'www'

    let(:attributes) { attributes_for(:company) }
    let(:url) { api_v1_companies_url(format: :json) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, company: attributes
      end.to change(Company, :count).by(1)
    end

    let(:created_company) { Company.last }

    it { should have_response_status(:created) }

    describe 'created company' do
      subject { created_company }

      its(:name) { should == attributes[:name] }
      its(:user_affiliations) { should have(1).item }
      its('user_affiliations.first.user') { should == user }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the company' do
        should be_json_eql(created_company.to_json)
      end
    end
  end
  
  describe 'POST /api/v1/companies/:id/create_advised_company.json' do
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}/create_advised_company" }

    let(:attributes) { {name: 'test test', subdomain: 'test-test'}  }
    let(:url) { create_advised_company_api_v1_company_url(company, format: :json) }

    before do
      company.upgrade_to_advisor!
      company.invite_user(user)

      expect do
        post_with_http_auth valid_credentials, url, company: attributes
      end.to change(Company, :count).by(1)
    end

    let(:created_company) { Company.last }

    it { should have_response_status(:created) }

    describe 'created company' do
      subject { created_company }

      its(:name) { should == attributes[:name] }
      its(:company_affiliations) { should have(1).item }
      its('advisor_company_affiliations.first.advisor_company_id') { should == company.id }
    end

    describe 'returned JSON' do
      subject { response.body }

      it 'should include the company' do
        should be_json_eql(created_company.to_json)
      end
    end
  end

  describe 'PUT /api/v1/companies/:id.json' do
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}" }

    let!(:other_country) { create(:country) }
    let(:attributes) { { name: 'New company name', url: 'http://this.is.an.url.com',
        postal_code: '24-313',
        country_id: other_country.id } }
    let(:url) { api_v1_company_url(company, format: :json ) }

    context 'on success' do
      before do
        expect do
          put_with_http_auth valid_credentials, url, company: attributes
        end.not_to change(Company, :count)
      end
      
      it { should have_response_status(:no_content) }

      describe 'updated company' do
        subject { company.reload }

        its(:name) { should == attributes[:name] }
        its(:postal_code) { should == attributes[:postal_code] }
        its(:url) { should == attributes[:url] }
        its(:country) { should == other_country }
      end
    end
  end

  describe 'PUT /api/v1/companies/:id/upgrade.json' do
    let(:url) { upgrade_api_v1_company_url(company, format: :json ) }
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}/upgrade" }

    before { put_with_http_auth valid_credentials, url }

    it 'should upgrade a company to the advisor' do
      upgraded_company = Company.find(company.id)
      upgraded_company.should be_an_instance_of(AdvisorCompany)
    end
  end

  describe 'PUT /api/v1/companies/:id/downgrade.json' do
    let(:url) { downgrade_api_v1_company_url(company, format: :json ) }
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}/downgrade" }

    before do
      company.upgrade_to_advisor!
      put_with_http_auth valid_credentials, url
    end

    it 'should upgrade a company to the advisor' do
      upgraded_company = Company.find(company.id)
      upgraded_company.should be_an_instance_of(Company)
    end
  end

  describe 'DELETE /api/v1/companies/:id.json' do
    let(:url) { api_v1_company_url(company, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(Company, :count).by(-1)
    end

    it { should have_response_status(:no_content) }
  end

  describe 'PUT /api/v1/companies/:id/invite_user.json' do
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}/invite_user" }

    let(:url) { invite_user_api_v1_company_url(company, format: :json) }

    context 'inviting advisor' do
      shared_examples_for 'respond with list of advisor companies' do |companies_count|
        it { should have_response_status(422) }

        it 'should not invite any advisor company' do
          affiliations = company.advisor_company_affiliations
          affiliations.should be_empty
        end

        describe 'response' do
          subject { response.body }
          it { should have_json_size(companies_count).at_path('companies') }
        end
      end
      
      let!(:advisor_user_email) { 'advisor@email.com' }
      let!(:advisor_user) { create(:user, email: advisor_user_email) }
      let!(:advisor_company) { create(:advisor_company, users: [advisor_user]) }
      
      context 'when an user has only one advisor company' do
        before { put_with_http_auth valid_credentials, url, { user: { email: advisor_user_email } } }
        
        it_behaves_like 'respond with list of advisor companies', 1

        describe 'response' do
          subject { response.body }

          it "should include user's advisor companies" do
            should have_json_size(1).at_path('companies')
            should include_json(advisor_company.to_json).at_path('companies')
          end
        end
      end

      context 'when an user has several advisor companies' do
        let!(:other_advisor_company) { create(:advisor_company, users: [advisor_user]) }
        before { put_with_http_auth valid_credentials, url, { user: { email: advisor_user_email } } }
        
        it_behaves_like 'respond with list of advisor companies', 2

        describe 'response' do
          subject { response.body }

          it "should include user's advisor companies" do
            should have_json_size(2).at_path('companies')
            should include_json(advisor_company.to_json).at_path('companies')
            should include_json(other_advisor_company.to_json).at_path('companies')
          end
        end
      end
      
      context 'when :ignoreIfAdvisor parameter is passed' do
        before { put_with_http_auth valid_credentials, url, { user: { email: advisor_user_email }, ignoreIfAdvisor: 'true'} }
        it { should have_response_status(:no_content) }

        it 'should set x-invitation-type in the response header' do
          response.headers['x-invitation-type'].should == "UserAffiliation"
        end
        
        it 'should add an user to the company' do
          user_affiliations = company.user_affiliations
          user_affiliations.should have(2).items
          user_affiliations.where(user_id: advisor_user.id).should be_present
        end
      end
    end
    
    context 'inviting existing user' do
      let(:user_email) { 'existing@user.com' }
      let!(:invited_user) { create(:user, email: user_email) }

      before { put_with_http_auth valid_credentials, url, { user: { email: user_email } } }

      it { should have_response_status(:no_content) }

      it 'should set x-invitation-type in the response header' do
        response.headers['x-invitation-type'].should == "UserAffiliation"
      end

      it 'should add an user to the company' do
        user_affiliations = company.user_affiliations
        user_affiliations.should have(2).items
        user_affiliations.where(user_id: invited_user.id).should be_present
      end
    end
    
    context 'inviting new user (email tests)' do
      let(:mailer) { mock(deliver: true) }

      it 'should send an email if invitation was created' do
        Notifications.should_receive(:company_invitation).with(anything).and_return(mailer)
        put_with_http_auth valid_credentials, url, { user: { email: 'not-registered@mail.com' } }
        company.invitations.should have(1).item
      end
      
      it "should not send email if user is already registered" do
        Notifications.should_not_receive(:company_invitation)
        put_with_http_auth valid_credentials, url, { user: { email: 'other.user@email.com' } }
        company.invitations.should have(0).items
      end
      
      it "should not send email if invitation is not valid" do
        Notifications.should_not_receive(:company_invitation)
        put_with_http_auth valid_credentials, url, { user: { email: '@@@' } }
        company.invitations.should have(0).items
      end
      
    end
    
    context 'inviting new user' do
      let(:user_email) { 'new@user.com' }
      
      before { put_with_http_auth valid_credentials, url, { user: { email: user_email } } }

      it { should have_response_status(:no_content) }

      it 'should set x-invitation-type in the response header' do
        response.headers['x-invitation-type'].should == "CompanyInvitation"
      end

      it 'should create an invitation' do
        invitations = company.invitations
        invitations.should have(1).item

        invitation = invitations.last
        invitation.email == user_email
        invitation.company == company
      end
    end
  end

  describe 'PUT /api/v1/companies/:id/invite_advisor.json' do
    it_should_have_api_endpoint(subdomain: 'www') { "companies/#{company.id}/invite_advisor" }

    let!(:advisor_user_email) { 'advisor@email.com' }
    let!(:advisor_user) { create(:user, email: advisor_user_email) }
    let!(:advisor_company) { create(:advisor_company, users: [advisor_user]) }

    let(:url) { invite_advisor_api_v1_company_url(company, format: :json) }

    context 'invite by advisor company id' do
      before { put_with_http_auth valid_credentials, url, { company: { id: advisor_company.id } } }

      it { should have_response_status(:no_content) }

      it "should invite advisor company" do
        affiliations = company.advisor_company_affiliations
        affiliations.should have(1).items
        affiliations.where(advisor_company_id: advisor_company.id).should be_present

        advisor_company.advised_companies.should include(company)
      end
    end
  end

  describe 'PUT /api/v1/companies/:id/remove_user.json' do
    let(:url) { remove_user_api_v1_company_url(company, format: :json) }
    
    let(:params) { { user: { id: user.id } } }
    before { put_with_http_auth valid_credentials, url, params }
    
    it "should remove user from company users" do
      company.reload.user_affiliations.map(&:user_id).should_not include user.id
    end
    
    it "should not remove the user itself" do
      lambda{user.reload.id}.should_not raise_error Mongoid::Errors::DocumentNotFound
    end
  end
  
  describe 'PUT /api/v1/companies/:id/remove_advised_company.json' do
    let!(:advisor_company) { create(:advisor_company, name: 'Advisor company', users: [user]) }

    let(:url) { remove_advised_company_api_v1_company_url(advisor_company, format: :json, subdomain: advisor_company.subdomain) }
    
    let(:params) { { company: { id: company.id } } }
    before do
      company.invite_advisor(advisor_company)
      put_with_http_auth valid_credentials, url, params
    end
    
    it "should remove company from the advised" do
      advisor_company.advised_companies.should_not include(company)
    end
    
    it "should not remove the company itself" do
      expect do
        company.reload.id
      end.not_to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end
end
