require 'spec_helper'

describe 'API v1 for users', :api do
  include_context 'stuff for the API integration specs'
  let!(:second_user) { create(:user, id: '17cc67093475061e3d95369d', email: 'second@user.com', companies: [first_company]) }

  describe 'GET /api/v1/users.json' do
    it_should_have_api_endpoint path: 'users'

    let(:url) { api_v1_users_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { encode_http_auth_credentials(user.email) }

      it { should have_response_status(:success) }

      it_behaves_like 'a GET :index with items' do
        let(:company) { first_company }
        let(:include_items) { [user, second_user] }
      end
    end
  end

  describe 'GET /api/v1/users/:id.json' do
    let(:url) { api_v1_user_url(user, format: :json, subdomain: company.subdomain) }

    before { get_with_http_auth valid_credentials, url }

    it { should have_response_status(:success) }

    describe 'returned JSON' do
      subject { response.body }

      specify 'included fields' do
        should have_json_path('id')
        should have_json_path('email')
        should have_json_path('name')
        should have_json_path('email_notifications')
        should have_json_path('updated_at')
        should have_json_path('created_at')
      end

      specify 'excluded fields' do
        should_not have_json_path('encrypted_password')
        should_not have_json_path('reset_password_token')
        should_not have_json_path('reset_password_sent_at')
      end

      it 'should include the user' do
        should be_json_eql(user.to_json)
      end
    end
  end

  describe 'POST /api/v1/users.json' do
     it_should_have_api_endpoint path: 'users'

     let(:attributes) { { name: 'New user', email: 'testuser@gmail.com', company_id: company.id,
                          password: '111111', password_confirmation: '111111' } }
     let(:url) { api_v1_users_url(format: :json, subdomain: company.subdomain) }

     before do
       expect do
         post_with_http_auth valid_credentials, url, user: attributes
         company.reload
       end.to change(company.user_affiliations, :count).by(1)
     end

     it_behaves_like 'an API request with response status', :created
     let(:created_user) { User.last }

     describe 'created vendor' do
       subject { created_user }

       its(:name) { should == 'New user' }
       its(:email) { should == 'testuser@gmail.com' }

       its(:companies) { should have(1).item }
       its(:companies) { should include(first_company) }
     end

     describe 'returned JSON' do
       subject { response.body }

       it 'should include the user' do
         should be_json_eql(created_user.to_json)
       end
     end
  end

  describe 'PUT /api/v1/users/:id.json' do
    let(:user_to_update) { user }
    let(:new_password) { 'new password' }
    let(:attributes) { { email: 'new.user@email.com', name: 'New Name',
                         password: new_password, password_confirmation: new_password } }
    let(:url) { api_v1_user_url(user_to_update, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, user: attributes
      end.not_to change(company.user_affiliations, :count)
      user_to_update.reload
    end

    context 'updating self' do
      let(:user_to_update) { user }

      it { should have_response_status(:no_content) }

      describe 'updated user' do
        subject(:updated_user) { user }

        its(:name) { should == 'New Name' }
        its(:email) { should == 'new.user@email.com' }
        it 'should have new password' do
          updated_user.valid_password?(new_password).should be_true
        end
      end
    end

    context 'updating other user' do
      let(:new_password) { 'other user password' }
      let(:user_to_update) { other_user }

      it { should have_response_status(:no_content) }

      describe 'updated user' do
        subject(:updated_user) { other_user }

        its(:email) { should == 'other.user@email.com' }
        it 'should not update the password' do
          updated_user.valid_password?(new_password).should be_false
        end
      end
    end
  end

  describe 'PUT /api/v1/users/:id/update_password.json' do
    let(:new_password) { 'new password' }
    let(:attributes) { { current_password: 'secret password',
                         password: new_password, password_confirmation: new_password } }
    let(:url) { update_password_api_v1_user_url(user, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, user: attributes
      end.not_to change(company.user_affiliations, :count)
      user.reload
    end

    context 'with valid attributes' do
      it { should have_response_status(:no_content) }

      describe 'updated user' do
        subject(:updated_user) { user }

        it 'should set the new password' do
          updated_user.valid_password?(new_password).should be_true
        end
      end
    end

    context 'with invalid attributes' do
      let(:new_password) { '123' }

      it { should have_response_status(:unprocessable_entity) }

      it 'should not set the new password' do
        user.valid_password?('secret password').should be_true
      end

      describe 'returned JSON' do
        subject { response.body }

        it 'should include :password errors' do
          should have_json_path('errors/password')
          should have_json_value(["is too short (minimum is 6 characters)"]).at_path('errors/password')
        end
      end
    end
  end

  describe 'DELETE /api/v1/users/:id.json' do
    it_should_have_api_endpoint { "users/#{second_user.id}" }

    let(:url) { api_v1_user_url(second_user, format: :json, subdomain: company.subdomain) }
    before { delete_with_http_auth valid_credentials, url }

    it { should have_response_status(:no_content) }

    it 'should delete the user' do
      expect do
        User.find(second_user.id)
      end.to raise_error(Mongoid::Errors::DocumentNotFound)
    end

    it 'should destroy dependent affiliation' do
      affiliations = company.reload.user_affiliations
      affiliations.where(user: second_user).first.should be_nil
    end
  end
end
