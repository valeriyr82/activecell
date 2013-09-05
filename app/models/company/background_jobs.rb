module Company::BackgroundJobs
  extend ActiveSupport::Concern

  included do
    has_many :background_jobs
  end

  # Endpoint for Etl background job
  def schedule_etl_batch(batch_type, enqueue = true)
    return unless connected_to_intuit?
    return unless can_schedule_new_job?

    if enqueue
      job_options = { company_id: self.id, batch_type: batch_type }
      batch_job = background_jobs.create!(options: job_options, status: :queued)

      uuid = ProcessEtlBatchJob.create(job_options)

      batch_job.update_attributes!(job_uuid: uuid)
      batch_job
    else
      ProcessEtlBatchJob::Worker.new(self, batch_type).process!
    end
  end

  # Returns true when new job can be scheduled
  # * no jobs were scheduled
  # * last job completed
  # * ..or last job failed
  def can_schedule_new_job?
    last_job = last_background_job
    !last_job.present? or last_job.failed? or last_job.completed?
  end

  def last_background_job
    background_jobs.order_by(created_at: :asc).last
  end

end
