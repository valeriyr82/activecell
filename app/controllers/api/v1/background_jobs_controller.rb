class Api::V1::BackgroundJobsController < Api::BaseController

  # Create a new background job
  def create
    job = current_company.schedule_etl_batch(:full, true)
    if job.present?
      respond_with(job, status: :created, location: nil)
    else
      respond_with(false, status: :unprocessable_entity, location: nil)
    end
  end

  # Fetch info about background job
  def last
    last_job = current_company.last_background_job
    respond_with(last_job)
  end

  def show
    job = current_company.background_jobs.find(params[:id])
    respond_with(job)
  end

end
