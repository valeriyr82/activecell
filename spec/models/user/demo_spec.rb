require 'spec_helper'

describe User::Demo do
  let(:user) { create(:user) }
  subject { user }

  describe 'fields' do
    it { should have_field(:demo_status).of_type(String) }
    it { should have_field(:last_activity).of_type(Time) }
  end

  describe 'scopes' do
    describe '.demo_inactive' do
      let(:user) { create :user }

      context 'when user is active' do
        it 'not return user' do
          User.demo_inactive.count.should == 0
        end
      end

      context 'when user with last active less then 1 hour from now' do
        it 'return user' do
          user.update_attribute :last_activity, Time.now.utc - 1.hours
          User.demo_inactive.first.should == user
        end
      end
    end
  end

  describe '.demo_take' do
    context 'when demo account exists' do
      let!(:user) { create(:user, demo_status: 'available') }

      it 'return a user' do
        User.demo_take.should == user
      end

      it 'take a demo user' do
        User.any_instance.should_receive(:demo_take)
        User.demo_take
      end
    end

    context 'when demo account does not exist' do
      it 'return nil' do
        User.demo_take.should be_nil
      end
    end
  end

  describe '#demo_take' do
    context 'when a demo user' do
      let!(:user) { create(:user, :with_demo_company, demo_status: 'available') }

      it 'return a user' do
        user.demo_take.should == user
      end

      it 'take a demo user' do
        user.demo_take.demo_status.should == 'taken'
      end

      it 'take a demo companies of a user' do
        user.demo_take.companies.each { |company| company.demo_status.should == 'taken' }
      end
    end

    context 'when not a demo user' do
      let!(:user) { create(:company) }

      it 'return nil' do
        user.demo_take.should be_nil
      end
    end
  end

  describe '#demo_active' do
    let(:user) { create(:user) }

    it 'set last active date' do
      user.demo_active
      user.last_activity.should_not be_nil
    end
  end

end
