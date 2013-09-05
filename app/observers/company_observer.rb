class CompanyObserver < Mongoid::Observer

  def before_destroy(company)
    terminate_subscription(company)
  end

  private

  # Terminates Recurly subscription
  def terminate_subscription(company)
    subscriber = subscriber_for(company)
    subscriber.terminate_subscription
  end

  def subscriber_for(company)
    company.subscriber
  end

end
