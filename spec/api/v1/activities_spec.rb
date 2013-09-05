require 'spec_helper'

describe 'API v1 for activities', :api, :activity_stream do
  include_context 'stuff for the API integration specs'

  let!(:activity) { create(:activity, content: 'Just do it!', company: company, sender: user) }
  let!(:second_activity) { create(:activity, content: 'Just do it 2!', company: company, sender: user) }
  let!(:third_activity) { create(:activity, content: 'Just do it 3!', company: second_company, sender: user) }

  describe 'GET /api/v1/activities.json' do
    it_should_have_api_endpoint path: 'activities'

    let(:url) { api_v1_activities_url(format: :json, subdomain: company.subdomain) }
    before { get_with_http_auth credentials, url }

    describe 'returned JSON' do
      subject { response.body }

      it { should have_json_size(2) }

      it 'should include all current user companies' do
        should include_json(activity.to_json)
        should include_json(second_activity.to_json)
        should_not include_json(third_activity.to_json)
      end
    end
  end

  describe 'POST /api/v1/activities.json' do
    let(:attributes) { {content: 'This is new task'}  }
    let(:url) { api_v1_activities_url(company, format: :json) }

    before do
      expect do
        post_with_http_auth valid_credentials, url, activity: attributes
      end.to change(Activity, :count).by(1)
    end

    describe 'created activity' do
      subject { Activity.last }

      its(:content) { should == attributes[:content] }
      its(:sender) { should == user }
      its(:company) { should == company }
    end

    describe 'returned JSON' do
      subject { response.body }

      xit 'should include the activity' do
        should be_json_eql(Activity.last.to_json)
      end
    end
  end

end
