# Encapsulates logic for managing Recurly subscriptions
class RecurlySubscriber
  attr_reader :company

  TRIAL_INTERVAL_LENGTH = 30

  def initialize(company)
    @company = company
  end

  delegate :subscription, to: :company, prefix: true
  delegate :created_at, to: :company, prefix: true
  delegate :billing_overridden?, to: :company, prefix: true

  # Returns identifier for uniquely identifying a company on Recurly's side
  # @see http://docs.recurly.com/accounts
  def account_code
    "#{company._id}@recurly"
  end

  # Returns current recurly subscription
  def subscription
    return nil if not company_subscription.present?
    @subscription ||= Recurly::Subscription.find(company_subscription.uuid)
  end

  # Subscribe to the given plan
  def subscribe_to_plan(plan_code, account = {})
    account.reverse_merge!(account_code: account_code)

    attributes = { plan_code: plan_code, account: account }
    subscription = Recurly::Subscription.create(attributes)
    update_company_subscription_details(subscription)
    subscription
  end

  # Sync company subscription details for subscription with given js token
  def update_company_subscription_by_token(token)
    subscription = Recurly.js.fetch(token)
    update_company_subscription_details(subscription)
    subscription
  end

  def change_plan_to(plan_code)
    return unless has_active_subscription?

    attributes = { plan_code: plan_code.to_s, timeframe: 'now' }
    subscription.update_attributes(attributes)
    update_company_subscription_details(subscription)
    subscription
  end

  # Returns true if the company has active recurly subscription
  def has_active_subscription?
    if company_subscription.present?
      # subscription is not expired
      return true if not company_subscription.expires_at.present?

      # otherwise check expiration date
      Time.now < company_subscription.expires_at
    else
      # user has never paid
      false
    end
  end

  # Returns true is an user cancelled his subscription
  def subscription_is_cancelled?
    has_active_subscription? and company_subscription.state == 'canceled'
  end

  def subscription_was_terminated_by_advisor?
    company_subscription.present? and company_subscription.terminated_by_advisor?
  end

  def in_trial?
    not (has_active_subscription? or company_billing_overridden?)
  end

  def trial_expired?
    in_trial? and trial_days_left < 0
  end

  def trial_days_left
    days_ago = ((Time.now - company_created_at) / (24 * 60 * 60)).floor
    TRIAL_INTERVAL_LENGTH - days_ago
  end

  # Cancel the subscription
  # @see http://docs.recurly.com/api/subscriptions
  def cancel_subscription
    return false unless has_active_subscription?

    cancelled = subscription.cancel
    update_company_subscription_details(subscription) if cancelled
    cancelled
  end

  # Terminate the subscription
  # @see http://docs.recurly.com/api/subscriptions
  def terminate_subscription
    return false unless has_active_subscription?

    # If terminating with refund if not possible..
    terminated = begin
      subscription.terminate(:full)
    rescue Recurly::API::BadRequest
      # ..fallback to terminate without the refund
      subscription.terminate(:none)
    end

    update_company_subscription_details(subscription) if terminated
    terminated
  end

  def to_json
    as_json.to_json
  end

  def as_json
    {
        account_code: account_code,
        has_active_subscription?: has_active_subscription?,
        subscription_is_cancelled?: subscription_is_cancelled?,
        subscription: company_subscription.present? ? company_subscription.as_json : nil
    }
  end

  private

  # Store subscription data locally
  def update_company_subscription_details(subscription)
    return unless subscription.valid?

    attributes = subscription_attributes_for(subscription)

    if company_subscription.present?
      company.subscription.attributes = attributes
      set_company_subscription_plan_details(subscription.plan_code) if company_subscription.plan_code_changed?
    else
      company.build_subscription(attributes)
      set_company_subscription_plan_details(subscription.plan_code)
    end
    company_subscription.save!

    @subscription = subscription
  end

  # Fetch and store subscription plan details
  def set_company_subscription_plan_details(plan_code)
    plan = Recurly::Plan.find(plan_code)

    company_subscription.plan_interval_length = plan.plan_interval_length
    company_subscription.plan_interval_unit = plan.plan_interval_unit
    company_subscription.plan_unit_amount_in_cents = plan.unit_amount_in_cents.to_i
  end

  def subscription_attributes_for(subscription)
    Hash.new.tap do |attr|
      attr[:uuid] = subscription.uuid
      attr[:state] = subscription.state

      attr[:plan_code] = subscription.plan.plan_code
      attr[:plan_name] = subscription.plan.name

      attr[:trial_ends_at] = subscription.trial_ends_at
      attr[:expires_at] = subscription.expires_at
    end
  end

end
