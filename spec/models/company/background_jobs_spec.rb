require 'spec_helper'

describe Company::BackgroundJobs, :background_jobs do
  let!(:company) { create(:company) }
  subject { company }

  describe 'associations' do
    it { have_many(:background_jobs) }
  end

  describe '#schedule_etl_batch' do
    let(:new_job_uuid) { 'job uuid' }
    let(:job_options) { { company_id: company.id, batch_type: :full } }

    before do
      company.should_receive(:connected_to_intuit?).and_return(true)
      company.should_receive(:can_schedule_new_job?).and_return(true)
      ProcessEtlBatchJob.should_receive(:create).with(job_options).and_return(new_job_uuid)
    end

    it 'should create background job record' do
      expect do
        company.schedule_etl_batch(:full)
      end.to change(BackgroundJob, :count).by(1)

      job = BackgroundJob.last

      job.company.should == company
      job.status.should == 'queued'
      job.job_uuid.should == new_job_uuid

      job.options['company_id'].should == company.id
      job.options['batch_type'].should == :full
    end
  end

  describe 'can_schedule_new_job?' do
    it { should respond_to(:can_schedule_new_job?) }

    describe 'result' do
      subject { company.can_schedule_new_job? }

      context 'when no jobs where scheduled' do
        it { should be_true }
      end

      context 'when all jobs are completed' do
        let!(:completed_job) { create(:background_job, :completed, company: company) }
        let!(:failed_job) { create(:background_job, :failed, company: company) }

        it { should be_true }

        context 'when there is a queued job' do
          let!(:working_job) { create(:background_job, :queued, company: company) }
          it { should be_false }
        end

        context 'when there is a job in progress' do
          let!(:working_job) { create(:background_job, :working, company: company) }
          it { should be_false }
        end
      end
    end
  end

  describe '#last_background_job' do
    it { should respond_to(:last_background_job) }

    describe 'result' do
      subject { company.last_background_job }

      context 'when no jobs where scheduled' do
        it { should be_nil }
      end

      context 'when several jobs where scheduled' do
        let!(:failed_job) { create(:background_job, :failed, company: company, created_at: 3.hours.ago) }
        let!(:first_job) { create(:background_job, :completed, company: company, created_at: 1.day.ago) }
        let!(:second_job) { create(:background_job, :working, company: company, created_at: 2.hours.ago) }

        it 'should be the last job' do
          should_not == failed_job
          should_not == first_job

          should == second_job
        end
      end
    end
  end

end
