require 'spec_helper'

describe ActivityObserver, :notifications do
  subject(:observer) { described_class.instance }
  let(:activity) { mock_model(Activity) }

  describe '#after_create' do
    it { should respond_to(:after_create) }

    let(:first_user) { mock_model(User) }
    let(:second_user) { mock_model(User) }
    let(:users) { [first_user, second_user] }

    it 'should notify all users about activity creation' do
      activity.should_receive(:users_to_notify).and_return(users)
      users.each do |user|
        Notifications.should_receive(:activity_created).with(activity.id, user.id).and_return(mock(deliver: true))
      end

      observer.after_create(activity)
    end
  end
end
