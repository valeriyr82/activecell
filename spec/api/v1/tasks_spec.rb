require 'spec_helper'

describe 'API v1 for tasks', :api do
  include_context 'stuff for the API integration specs'

  let!(:task) { create(:task, company: first_company, text: 'Just do it!') }
  let!(:second_task) { create(:task, company: first_company) }
  let!(:third_task) { create(:task, company: second_company) }

  describe 'GET /api/v1/tasks.json' do
    it_should_have_api_endpoint path: 'tasks'

    let(:url) { api_v1_tasks_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    context 'with valid credentials' do
      let(:credentials) { valid_credentials }
      it_behaves_like 'an API request with response status', :success
      it_behaves_like 'an API with JSON' do
        let(:first_group)  { [task, second_task] }
        let(:second_group) { [third_task] }
      end
    end

    it_behaves_like 'an API request with invalid basic http credentials'
  end

  describe 'GET /api/v1/tasks/:id.json' do
    it_should_have_api_endpoint { "tasks/#{task.id}" }

    let(:url) { api_v1_task_url(task, format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth valid_credentials, url }

    it_behaves_like 'an API request with response status', :success
    it_behaves_like 'an API request error for the other company'

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_value('Just do it!').at_path('text') }
    end
  end

  describe 'POST /api/v1/tasks.json' do
    
    shared_examples_for 'json response for created task' do
      describe 'returned JSON' do
        subject { response.body }

        it 'should include the task' do
          should be_json_eql(created_task.to_json)
        end
      end
    end
    
    it_should_have_api_endpoint path: 'tasks'
    let(:url) { api_v1_tasks_url(format: :json, subdomain: company.subdomain) }

    describe 'without passing user_id' do
      let(:attributes) { {text: 'Do that!'} }
      
      before do
        expect do
          post_with_http_auth valid_credentials, url, task: attributes
        end.to change(company.tasks, :count).by(1)
      end

      it_behaves_like 'an API request with response status', :created
      let(:created_task) { company.tasks.last }
      it_behaves_like 'json response for created task'

      describe 'created task' do
        subject { created_task }

        its(:text) { should == attributes[:text] }
        its(:company) { should == first_company }
        its(:user) { should == user }
      end

      
    end
    
    describe 'with user_id' do
      describe 'from the same company' do
        let(:second_user) { create(:user, email: '2nduser@email.com', password: 'secret password') }
        
        before do
          company.invite_user(second_user)
          @attributes = {text: 'Do that!', user_id: second_user.id}
          
          expect do
            post_with_http_auth valid_credentials, url, task: @attributes
          end.to change(company.tasks, :count).by(1)
        end

        it_behaves_like 'an API request with response status', :created
        let(:created_task) { company.tasks.last }
        it_behaves_like 'json response for created task'

        describe 'created task' do
          subject { created_task }

          its(:text) { should == @attributes[:text] }
          its(:company) { should == first_company }
          its(:user) { should == second_user }
        end
        
      end
      
      describe 'from some other company' do
        let(:attributes) { {text: 'Do that!', user_id: other_user.id} }
        before do
          expect do
            post_with_http_auth valid_credentials, url, task: attributes
          end.not_to change(company.tasks, :count).by(1)
        end
        
        it { response.body.should have_json_path('errors/user') }
        it { should have_response_status(422) }
      end
    end

  end

  describe 'PUT /api/v1/tasks/:id.json' do
    it_should_have_api_endpoint { "tasks/#{second_task.id}" }

    let(:attributes) { { text: "Winston's Cigars" } }
    let(:url)        { api_v1_task_url(second_task, format: :json, subdomain: company.subdomain) }

    before do
      expect do
        put_with_http_auth valid_credentials, url, task: attributes
      end.not_to change(company.tasks, :count)
    end

    it_behaves_like 'an API request with response status', :no_content

    describe 'updated task' do
      subject { second_task.reload }

      its(:text) { should == attributes[:text] }
    end
  end

  describe 'DELETE /api/v1/tasks/:id.json' do
    it_should_have_api_endpoint { "tasks/#{second_task.id}" }

    let(:url) { api_v1_task_url(second_task, format: :json, subdomain: company.subdomain) }
    before do
      expect do
        delete_with_http_auth valid_credentials, url
      end.to change(company.tasks, :count).by(-1)
    end

    it_behaves_like 'an API request with response status', :no_content
  end
end
