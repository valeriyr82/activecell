shared_context 'stuff for the API integration specs' do
  include ApiExampleGroup

  before do
    fixtures = SmartFixtures.instance
    fixtures.capture('API integration specs') do
      user = create(:user, email: 'user@email.com', password: 'secret password')
      other_user = create(:user, email: 'other.user@email.com', password: 'secret password')

      create(:company, name: 'First company', subdomain: 'first-company', users: [user])
      create(:company, name: 'Second company', subdomain: 'second-company', users: [user])
      create(:company, name: 'Third company', subdomain: 'third-company', users: [other_user])
    end
  end

  let(:user) { User.where(email: 'user@email.com').first }
  let(:other_user) { User.where(email: 'other.user@email.com').first }

  let(:first_company) { Company.where(subdomain: 'first-company').first }
  let(:second_company) { Company.where(subdomain: 'second-company').first }
  let(:third_company) { Company.where(subdomain: 'third-company').first }
  let(:company) { first_company }

  include_context 'basic http auth for api calls'
end

shared_context 'basic http auth for api calls' do
  let(:valid_credentials) do
    encode_http_auth_credentials(user.email, 'secret password')
  end

  let(:invalid_credentials) do
    encode_http_auth_credentials(user.email, 'invalid password')
  end

  let(:credentials) { valid_credentials }
end

shared_context 'stubbed #current_user and #current_company' do
  let(:current_company) { mock_model(Company) }
  let(:current_user) { mock_model(User, companies: [current_company]) }

  before do
    controller.stub(:current_company).and_return(current_company)
    controller.stub(:current_user).and_return(current_user)
  end
end
