require 'spec_helper'

describe TaskObserver, :notifications do
  subject(:observer) { described_class.instance }
  let(:task) { mock_model(Task) }

  describe '#after_create' do
    it { should respond_to(:after_create) }

    let(:first_user) { mock_model(User) }
    let(:second_user) { mock_model(User) }
    let(:users) { [first_user, second_user] }

    it 'should notify all users about activity creation' do
      task.should_receive(:users_to_notify).and_return(users)
      users.each do |user|
        Notifications.should_receive(:task_created).with(task.id, user.id).and_return(mock(deliver: true))
      end

      observer.after_create(task)
    end
  end

  describe '#after_update' do
    it { should respond_to(:after_create) }

    let(:first_user) { mock_model(User) }
    let(:second_user) { mock_model(User) }
    let(:users) { [first_user, second_user] }

    context 'when the task has been completed' do
      before { task.should_receive(:has_been_completed?).and_return(true) }

      it 'should notify all users about activity creation' do
        task.should_receive(:users_to_notify).and_return(users)
        users.each do |user|
          Notifications.should_receive(:task_completed).with(task.id, user.id).and_return(mock(deliver: true))
        end

        observer.after_update(task)
      end
    end

    context 'otherwise' do
      before { task.should_receive(:has_been_completed?).and_return(false) }

      it 'should do nothing' do
        observer.after_update(task)
      end
    end
  end
end
