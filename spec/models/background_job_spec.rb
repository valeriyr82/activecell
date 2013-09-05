require 'spec_helper'

describe BackgroundJob, :background_jobs do
  let!(:background_job) { create(:background_job, :working) }
  subject { background_job }

  describe 'fields' do
    it { should have_field(:job_uuid).of_type(String) }
    it { should have_field(:options).of_type(Hash) }
    it { should have_field(:status).of_type(String).with_default_value_of(:working) }
    it { should have_field(:message).of_type(String) }
    it { should have_field(:completed_at).of_type(Time) }

    it { should be_timestamped_document }
  end

  it { should have_index_for(completed_at: 1) }

  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'statuses' do
    describe 'queued?' do
      it 'should return true when status is :queued' do
        background_job.status = 'queued'
        background_job.queued?.should be_true

        background_job.status = 'completed'
        background_job.queued?.should be_false
      end
    end

    describe 'working?' do
      it 'should return true when status is :working' do
        background_job.status = 'working'
        background_job.working?.should be_true

        background_job.status = 'completed'
        background_job.working?.should be_false
      end
    end

    describe 'failed?' do
      it 'should return true when status is :failed' do
        background_job.status = 'failed'
        background_job.failed?.should be_true

        background_job.status = 'completed'
        background_job.failed?.should be_false
      end
    end

    describe 'completed?' do
      it 'should return true when status is :completed' do
        background_job.status = 'completed'
        background_job.completed?.should be_true

        background_job.status = 'failed'
        background_job.completed?.should be_false
      end
    end
  end

  describe 'to_json' do
    it { should respond_to(:to_json) }

    describe 'result' do
      let(:background_job) { create(:background_job, :completed, job_uuid: 'some uuid') }
      subject { background_job.to_json }

      it { should have_json_path('id') }
      it { should have_json_path('company_id') }
      it { should have_json_path('completed_at') }
      it { should have_json_path('created_at') }
      it { should have_json_path('updated_at') }
      it { should have_json_path('job_uuid') }
      it { should have_json_path('options') }

      it { should have_json_path('status') }
      it { should have_json_value('completed').at_path('status') }

      it { should_not have_json_path('job_status') }

      context 'when the job is in progress' do
        let(:job_status_hash) do
          {
              total: 41,
              num: 100,
              message: 'Processing step 41 of 100',
              status: 'working'
          }
        end

        before do
          Resque::Plugins::Status::Hash.should_receive(:get).with('some uuid').and_return(job_status_hash)
          background_job.update_attributes!(status: :working)
        end

        it { should have_json_path('job_status') }
        it { should have_json_path('job_status/total') }
        it { should have_json_path('job_status/num') }
        it { should have_json_path('job_status/message') }
        it { should have_json_path('job_status/status') }
      end
    end
  end

end
