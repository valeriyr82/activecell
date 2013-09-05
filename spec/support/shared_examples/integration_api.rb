shared_examples 'an API request with invalid basic http credentials' do
  let(:credentials) { invalid_credentials }

  describe 'response' do
    subject { response }

    its(:status) { should == 403 }
    its(:body) { should have_json_size(0) }
  end
end

shared_examples 'an API request with response status' do |symbol|
  describe 'response status' do
    subject { response.status }
    specify do
      status_code = Shoulda::Matchers::ActionController::RespondWithMatcher.new(symbol)
      should == status_code.instance_eval { @status }
    end
  end
end

shared_examples 'an API request error for the other company' do
  let(:company) { second_company }

  it_behaves_like 'an API request with response status', :not_found

  describe 'returned JSON' do
    subject { response.body }

    it { should have_json_path('error') }
    it { should have_json_type(String).at_path('error') }
  end
end

shared_examples 'a GET :index with items' do
  describe 'returned JSON' do
    subject { response.body }

    it { should have_json_size(include_items.size) }
    it 'should include all values' do
      include_items ||= []
      include_items.each { |item| should include_json(item.to_json) }

      exclude_items ||= []
      exclude_items.each { |item| should_not include_json(item.to_json) }
    end
  end
end

shared_examples 'an API with JSON' do
  context 'for first_company' do
    it_behaves_like 'a GET :index with items' do
      let(:company)       { first_company }
      let(:include_items) { first_group }
      let(:exclude_items) { second_group }
    end
  end

  context 'for second_company' do
    it_behaves_like 'a GET :index with items' do
      let(:company)       { second_company }
      let(:include_items) { second_group }
      let(:exclude_items) { first_group }
    end
  end
end

shared_examples 'confirm that at least 1 record exists' do
  before { delete_with_http_auth valid_credentials, second_url }
  it_behaves_like 'an API request with response status', :unprocessable_entity
end

shared_examples 'forecast with occurrence' do |name, have_fields, have_not_fields|
  context "#{name} occurrence" do
    subject { response.body }

    have_fields.each do |have_field|
      it { should have_json_path(have_field) }
    end

    have_not_fields.each do |have_not_field|
      it { should_not have_json_path(have_not_field) }
    end
  end
end
