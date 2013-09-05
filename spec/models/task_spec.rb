require 'spec_helper'

describe Task do
  after(:each) { back_to_the_present }

  describe 'fields' do
    it { should have_field(:text).of_type(String) }
    it { should have_field(:recurring).of_type(String) }
    it { should have_field(:done).of_type(Boolean) }
    it { should have_field(:done_at).of_type(DateTime) }
    it { should have_field(:recurrence_start).of_type(DateTime) }

    it { should be_timestamped_document }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:company) }
  end

  describe 'validations' do
    it { should validate_presence_of(:text) }
  end

  describe 'toggling done' do
    let!(:task) { create(:task) }
    let!(:done_task) { create(:task, done: true, done_at: Time.now) }

    it "should save current date when marking task as done" do
      task.done = true
      task.save
      
      task.reload
      task.done_at.should_not be_nil
    end
    
    it "should not save current date when marking task as not done" do
      task.text = 'update this task!'
      task.save
      
      task.reload
      task.done_at.should be_nil
    end
    
    it "should not delete done_at when toggling done to false" do
      done_task.done = false
      done_task.save
      done_task.done_at.should_not be_nil
    end
  end

  describe 'recurrent tasks' do 
    describe 'updating recurrence' do
      let!(:task) { create(:task) }
      let!(:task_annual) { create(:task, recurring: 'annualy', recurrence_start: 11.months.ago) }
    
      it "should save recurrence_start when updating recurring" do
        task.recurring = 'monthly'
        task.save
      
        task.reload
        task.recurrence_start.should_not be_nil
      end
    
      it "should clear recurrence_start when removing recurrence" do
        task_annual.recurring = nil
        task_annual.save
      
        task_annual.reload
        task_annual.recurrence_start.should be_nil
      end
    end

    describe 're-open recurring task' do
      let!(:task) {create(:task, done_at: 33.days.ago, done: true, recurring: 'monthly', recurrence_start: 2.months.ago)}
      let!(:task_annual) {create(:task, done_at: 9.months.ago, done: true, recurring: 'annualy', recurrence_start: 10.months.ago)}
      before do 
        Task.reactivate_recurring!
        [task, task_annual].each {|t| t.reload}
      end
    
      it "should set task as undone after the recurring period passed" do
        task.done.should be_false
      end
    
      it "should not set task as undone before the recurring period passed" do
        task_annual.done.should be_true
      end
    end
  
    describe 'monthly recurring tasks' do
      describe 'on the beginning of the month' do
        before { time_travel_to(Time.now.beginning_of_month + 1.day) }
      
        it "should reopen task done last month" do
          task = create(:task, done_at: 2.days.ago, done: true, recurring: 'monthly', recurrence_start: 1.month.ago)
          Task.reactivate_recurring!
          task.reload.done.should be_false
        end
      
        it "should reopen task done two months ago" do
          time_travel_to(Time.now.beginning_of_month)
          task = create(:task, done_at: 40.days.ago, done: true, created_at: 55.days.ago, recurring: 'monthly', recurrence_start: 3.months.ago)
          Task.reactivate_recurring!
          task.reload.done.should be_false
        end
      end
    end
  
    describe 'quarterly recurring tasks' do
      it "should reopen task for 2nd quarter" do
        time_travel_to('1 October 2012'.to_time)
        task = create(:task, done_at: "30 September 2012".to_time, done: true, recurring: 'quarterly', recurrence_start: '10 July 2012'.to_time)
        
        Task.reactivate_recurring!
        task.reload.done.should be_false
      end
      
      it "should reopen task for 3nd quarter" do
        time_travel_to('5 May 2012'.to_time)
        task = create(:task, done_at: "2 January 2012".to_time, done: true, recurring: 'quarterly', recurrence_start: '1 January 2012'.to_time)
        
        Task.reactivate_recurring!
        task.reload.done.should be_false
      end
      
      it "should reopen task for 2nd and a half quarter" do
        time_travel_to('20 April 2012'.to_time)
        task = create(:task, done_at: "2 January 2012".to_time, done: true, recurring: 'quarterly', recurrence_start: '1 January 2012'.to_time)
        
        Task.reactivate_recurring!
        task.reload.done.should be_false
      end
      
      it "should not reopen task which is done for current quarter" do
        time_travel_to('20 February 2012'.to_time)
        task = create(:task, done_at: "2 January 2012".to_time, done: true, recurring: 'quarterly', recurrence_start: '1 January 2012'.to_time)
        Task.reactivate_recurring!
        task.reload.done.should be_true
      end
    end
    
    describe 'scanning collection for tasks to reopen' do
      let!(:company) { create(:company) }
      let!(:company_2) { create(:company) }
      let!(:task_to_reopen) { create(:task, company: company, done_at: 40.days.ago, done: true, created_at: 55.days.ago, recurring: 'monthly', recurrence_start: 3.months.ago) }
      let!(:task_to_reopen_different_company) { create(:task, company: company_2, done_at: 40.days.ago, done: true, created_at: 55.days.ago, recurring: 'monthly', recurrence_start: 3.months.ago) }
      let!(:task_to_stay_closed) { create(:task, company: company, done_at: 1.day.ago, done: true, created_at: 55.days.ago, recurring: 'monthly', recurrence_start: 3.months.ago) }
      
      before { Task.where(company: company).reactivate_recurring! }
      
      it "should reopen tasks for new period" do
        task_to_reopen.reload
        task_to_reopen.done.should be_false
      end
      
      it "should not touch tasks out of the given scope" do
        task_to_reopen_different_company.reload
        task_to_reopen_different_company.done.should be_true
      end
      
      it "should leave tasks done if done for the current period" do
        task_to_stay_closed.reload
        task_to_stay_closed.done.should be_true
      end
    end
  end

  describe '#users_to_notify', :notifications do
    it { should respond_to(:users_to_notify) }

    let(:task) { build(:task) }

    let(:user) { mock_model(User) }
    let(:users) { mock }

    before do
      task.stub_chain(:company, :users).and_return(users)
      task.stub(user: user)
    end

    it 'should return all users from the corresponding company except the creator' do
      ActiveCell::Queries::UsersToNotify.should_receive(:for).with(users, except: user.id)
      task.users_to_notify
    end
  end

  describe '#has_been_completed?' do
    it { should respond_to(:has_been_completed?) }

    context 'when :done field has been changed to true' do
      let(:task) { create(:task, :incompleted) }
      before { task.done = true }
      it { expect(task.has_been_completed?).to be(true) }
    end

    context 'otherwise' do
      let(:task) { create(:task, :completed) }
      before { task.done = false }
      it { expect(task.has_been_completed?).to be(false) }
    end
  end
end
