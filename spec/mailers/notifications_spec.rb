require 'spec_helper'

describe Notifications, :notifications do

  shared_examples 'default email avatar' do
    describe 'avatar in the footer' do
      let(:avatar_url) { 'http://gravatar.com/avatar/default_avavar' }
      before { Gravatar.should_receive(:url_for).with('adam@activecell.com').and_return(avatar_url) }

      it('should include default avatar url') { should include(avatar_url) }
      it { should include('adam neary | founder & ceo') }
      it { should include('www.activecell.com') }
    end
  end

  shared_examples 'user email avatar' do
    describe 'avatar in the footer' do
      let(:avatar_url) { 'http://gravatar.com/avatar/user_avavar' }
      before { Gravatar.should_receive(:url_for).with(created_by.email).and_return(avatar_url) }

      it('should include creator avatar url') { should include(avatar_url) }
      it('should include creator name') { should include(created_by.name.downcase) }
      it('should include creator email') { should include(created_by.email) }
    end
  end

  describe '#sign_up' do
    let(:company) { mock_model(Company, name: 'Draper') }
    let(:email) { 'tester@gmail.com' }

    before do
      Company.should_receive(:find).with(company.id).and_return(company)
    end

    let(:mail) { Notifications.sign_up(company.id, email) }

    describe 'mail' do
      subject { mail }

      its(:subject) { should == 'welcome to activecell' }
      its(:to) { should include(email) }
      its(:from) { should include('noreply@activecell.com') }
    end

    describe 'rendered body' do
      subject { mail.body.encoded }

      it { should match('hello there!') }
      it { should match("you've just signed up Draper for activecell.") }
      include_examples 'default email avatar'
    end
  end
  
  describe '#company_invitation' do
    let(:company) { mock_model(Company, name: 'Test company') }
    let(:invitation) { mock_model(CompanyInvitation, company: company, email: 'test@email.com', token: 'the token') }

    before do
      CompanyInvitation.should_receive(:find).with(invitation.id).and_return(invitation)
    end

    let(:mail) { Notifications.company_invitation(invitation.id) }

    describe 'mail' do
      subject { mail }

      its(:subject) { should == 'you were invited to activecell' }
      its(:to) { should include('test@email.com') }
      its(:from) { should include('noreply@activecell.com') }
    end
    
    describe 'rendered body' do
      subject { mail.body.encoded }

      it { should include('Test company') }
      it { should include(new_user_registration_url(:t => 'the token')) }
      include_examples 'default email avatar'
    end
  end

  describe '#activity_created' do
    let(:user) { mock_model(User, email: 'user@email.com') }
    let(:created_by) { mock_model(User, email: 'creator@email.com', name: 'Luke Skywalker') }
    let(:activity) { mock_model(Activity, user: created_by, content: 'Activity content') }

    before do
      Activity.should_receive(:find).with(activity.id).and_return(activity)
      User.should_receive(:find).with(user.id).and_return(user)
    end

    let(:mail) { Notifications.activity_created(activity.id, user.id) }

    describe 'mail' do
      subject { mail }

      its(:subject) { should == 'a message from activecell' }
      its(:to) { should include('user@email.com') }
      its(:from) { should include('noreply@activecell.com') }
    end

    describe 'rendered body' do
      subject { mail.body.encoded }

      it { should_not be_empty }
      it { should include('Activity content') }
      include_examples 'user email avatar'
    end
  end

  describe 'notifications for task list' do
    let(:user) { mock_model(User, email: 'user@email.com', name: 'Luke Skywalker') }
    let(:created_by) { mock_model(User, email: 'creator@email.com', name: 'Luke Skywalker') }
    let(:task) { mock_model(Task, user: created_by, text: 'This is a new task') }

    before do
      Task.should_receive(:find).with(task.id).and_return(task)
      User.should_receive(:find).with(user.id).and_return(user)
    end

    describe '#task_created' do
      let(:mail)  { Notifications.task_created(task.id, user.id) }

      describe 'mail' do
        subject { mail }

        its(:subject) { should == 'an activecell task was assigned to you' }
        its(:to) { should include('user@email.com') }
        its(:from) { should include('noreply@activecell.com') }
      end

      describe 'rendered body' do
        subject { mail.body.encoded }

        it { should_not be_empty }
        it { should include('This is a new task') }
        include_examples 'user email avatar'
      end
    end

    describe '#task_completed' do
      let(:mail) { Notifications.task_completed(task.id, user.id) }

      describe 'mail' do
        subject { mail }

        its(:subject) { should == 'an activecell task was just completed' }
        its(:to) { should include('user@email.com') }
        its(:from) { should include('noreply@activecell.com') }
      end

      describe 'rendered body' do
        subject { mail.body.encoded }

        it { should_not be_empty }
        it { should include('This is a new task') }
        include_examples 'user email avatar'
      end
    end
  end

end
