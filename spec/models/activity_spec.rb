require 'spec_helper'

describe Activity, :activity_stream do

  describe 'fields' do
    it { should have_field(:content).of_type(String) }

    it { should be_timestamped_document }
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:sender).of_type(User) }
  end

  describe 'scopes' do
    describe '#recent' do
      let!(:first) { create(:activity, created_at: 4.months.ago) }
      let!(:second) { create(:activity, created_at: 2.months.ago) }
      let!(:third) { create(:activity, created_at: 1.month.ago) }

      subject(:result) { Activity.recent }

      it 'should return recent messages' do
        should have(2).item
        should_not include(first)

        result.first.should == third
        result.second.should == second
      end
    end
  end

  describe '#to_json' do
    it { should respond_to(:to_json) }

    let(:user) { create(:user, name: 'Luke Skywalker', email: 'luke@theforce.com') }
    let(:activity) { create(:activity, sender: user, created_at: 2.hours.ago) }

    describe 'result' do
      subject { activity.to_json }

      it { should have_json_path('id') }
      it { should have_json_path('content') }
      it { should have_json_value('about 2 hours ago').at_path('created_at_in_words') }

      it { should have_json_path('sender') }
      it { should have_json_value('Luke Skywalker').at_path('sender/name') }
      it { should have_json_value('luke@theforce.com').at_path('sender/email') }
    end
  end

  describe '#users_to_notify', :notifications do
    it { respond_to(:users_to_notify) }

    let(:activity) { build(:activity) }

    let(:user) { mock_model(User) }
    let(:users) { mock }

    before do
      activity.stub_chain(:company, :users).and_return(users)
      activity.stub(sender: user)
    end

    it 'should return all users from the corresponding company except the creator' do
      ActiveCell::Queries::UsersToNotify.should_receive(:for).with(users, except: user.id)
      activity.users_to_notify
    end
  end
end
