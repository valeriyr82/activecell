shared_examples_for 'an api document with name' do
  describe 'fields' do
    it { should have_field(:name).of_type(String) }
  end

  describe 'validations' do
    it { validate_uniqueness_of(:name) }
  end
end

shared_examples_for 'an api document which belongs to company' do
  describe 'associations' do
    it { belong_to(:company) }
  end

  describe 'validations' do
    it { validate_uniqueness_of(:name).scoped_to(:company_id) }
  end
end

shared_examples_for 'an api period document' do
  it_behaves_like 'an api document which belongs to company'

  describe 'associations' do
    it { belong_to(:period) }
  end
end

shared_examples_for 'an api occurence document' do
  describe 'fields' do
    it { should have_field(:occurrence).of_type(String) }
    it { should have_field(:occurrence_month).of_type(Integer) }
  end
end

shared_examples_for 'an api summary document' do
  describe 'fields' do
    it { should have_field(:document_type).of_type(String) }
    it { should have_field(:document_id).of_type(String) }
    it { should have_field(:document_line).of_type(String) }
    it { should have_field(:transaction_date).of_type(Date) }
  end
end

shared_examples_for 'success JSON response' do
  it { should respond_with(:success) }
  it { should respond_with_content_type(:json) }
end

shared_examples_for 'created JSON response' do
  it { should respond_with(:created) }
  it { should respond_with_content_type(:json) }
end

shared_examples_for 'unprocessable_entity JSON response' do
  it { should respond_with(:unprocessable_entity) }
  it { should respond_with_content_type(:json) }
end

shared_examples_for 'no_content JSON response' do
  it { should respond_with(:no_content) }
  it { should respond_with_content_type(:json) }
end

shared_examples_for 'an API :index action' do
  describe 'on GET to :index' do
    before { get :index, format: :json }
    include_examples 'success JSON response'
  end
end

shared_examples_for 'an API :show action' do
  describe 'on GET to :show' do
    before { get :show, format: :json, id: id }
    include_examples 'success JSON response'
  end
end

shared_examples_for 'an API :create action' do |record_name|
  describe 'on POST to :create' do
    let(:record) { public_send(record_name) }

    before do
      record.stub(errors: errors)
      post :create, params.merge(format: :json)
    end

    context 'on success' do
      let(:errors) { [] }
      include_examples 'created JSON response'
    end

    context 'on failure' do
      let(:errors) { %w(errors) }
      include_examples 'unprocessable_entity JSON response'
    end
  end
end

shared_examples 'an API :update action' do |record_name|
  let(:record) { public_send(record_name) }

  describe 'on PUT to :update' do
    before do
      record.should_receive(:update_attributes).with(params[record_name])
      record.stub(errors: errors)
      put :update, params.merge(format: :json)
    end

    context 'on success' do
      let(:errors) { [] }
      include_examples 'no_content JSON response'
    end

    context 'on errors' do
      let(:errors) { %w(errors) }
      include_examples 'unprocessable_entity JSON response'
    end
  end
end

shared_examples 'an API :delete action' do |record_name|
  let(:record) { public_send(record_name) }

  describe 'on DELETE to :destroy' do
    before do
      record.should_receive(:destroy)
      delete :destroy, params.merge(format: :json)
    end

    include_examples 'no_content JSON response'
  end
end
