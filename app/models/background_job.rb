class BackgroundJob
  include Mongoid::Document
  include Mongoid::Timestamps

  STATUES = [:queued, :working, :failed, :completed].freeze

  field :job_uuid, type: String
  field :options, type: Hash
  # status: queued, working, completed, failed
  field :status, type: String, default: :working
  field :message, type: String
  field :completed_at, type: Time

  index({ completed_at: 1 })

  belongs_to :company

  # Define methods for checking status, for instance job.working?
  STATUES.each do |status|
    define_method "#{status}?" do
      self.status == status.to_s
    end
  end

  def as_json(options = {})
    super(options).tap do |json|
      # if job is working, fetch its progress
      if working?
        job_status = Resque::Plugins::Status::Hash.get(job_uuid)
        json[:job_status] = job_status
      end
    end
  end
end
