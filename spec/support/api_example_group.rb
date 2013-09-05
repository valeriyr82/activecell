# Example group for API related integration specs
# @see https://github.com/rspec/rspec-rails/blob/master/lib/rspec/rails/example/request_example_group.rb
module ApiExampleGroup
  extend ActiveSupport::Concern
  include ActionDispatch::Integration::Runner

  included do
    # Set of http methods with basic http authentication
    # For example get_with_http_auth(credentials, '/some/resource.json')
    [:get, :post, :put, :delete].each do |http_method|
      define_method :"#{http_method}_with_http_auth" do |credentials, path, params = {}|
        public_send http_method, path, params, { 'HTTP_AUTHORIZATION' => credentials }
      end
    end

    before do
      @routes = ::Rails.application.routes
    end
  end

  def app
    ::Rails.application
  end

  def encode_http_auth_credentials(login, password = 'secret password')
    ActionController::HttpAuthentication::Basic.encode_credentials(login, password)
  end

  module ClassMethods

    def it_should_have_api_endpoint(options = {}, &block)
      describe 'API endpoint' do
        subject { url }

        it do
          options.reverse_merge! subdomain: company.subdomain
          path = options[:path]

          path = self.instance_eval(&block) if path.nil? and block_given?
          should == "http://#{options[:subdomain]}.example.com/api/v1/#{path}.json"
        end
      end
    end

  end
end
