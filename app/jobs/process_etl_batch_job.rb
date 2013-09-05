# TODO write specs for this class
class ProcessEtlBatchJob
  include Resque::Plugins::Status

  @queue = :etl

  class Worker
    attr_reader :company
    attr_reader :batch_type

    def initialize(company, batch_type = :full)
      @company = company
      @batch_type = batch_type
    end

    def process!
      ETL::Engine.process(control_file, {
          :authentication => authentication_hash,
          :company_id => company.id
      })
    ensure
      # Clean the cache after the execution finished
      ETLCache.sweep_resolvers!
    end

    private

    def intuit_company
      company.intuit_company
    end

    def provider
      intuit_company.provider
    end

    def authentication_hash
      {
          :company => company.id,
          :realm => intuit_company.realm,
          :provider => intuit_company.provider,
          :oauth_token => intuit_company.oauth_token
      }
    end

    def control_file
      "config/etl/#{provider}/#{provider}_#{batch_type}.ebf".downcase
    end
  end

  def perform
    background_job.update_attributes!(status: :working)
    puts "Staring job<#{uuid}> for #{company.inspect}, batch_type: #{batch_type}"
    puts "Background job: #{background_job.inspect}"

    ActiveSupport::Notifications.subscribe('job_progress.profitably-etl') do |name, start, finish, id, payload|
      num = payload[:num]
      total = payload[:total]

      at(num, total, "Processing directive #{num} of #{total}")
    end

    begin
      worker = Worker.new(company, batch_type)
      worker.process!
    rescue Exception => error
      background_job.update_attributes!(status: :failed, completed_at: Time.now, message: error.message)
      raise error
    ensure
      ActiveSupport::Notifications.unsubscribe('job_progress.profitably-etl')
    end

    completed("Finished!")
    background_job.update_attributes!(status: :completed, completed_at: Time.now)
  end

  private

  def company
    @company ||= begin
      company_id = options['company_id']
      Company.find(company_id)
    end
  end

  def batch_type
    options['batch_type'].to_sym
  end

  def background_job
    @background_job ||= company.last_background_job
  end

end
