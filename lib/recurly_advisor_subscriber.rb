# Encapsulates logic for managing Recurly subscriptions
class RecurlyAdvisorSubscriber < RecurlySubscriber
  ADVISED_COMPANY_ADD_ON_CODE = 'advised_company'

  def add_advised_company(company)
    if terminate_subscription_for(company)
      new_quantity = advised_company_add_ons_quantity + 1
      update_advised_company_add_ons_quantity(new_quantity)
    end
  end

  def remove_advised_company(company)
    if renew_terminated_subscription_for(company)
      new_quantity = advised_company_add_ons_quantity - 1
      update_advised_company_add_ons_quantity(new_quantity)
    end
  end

  # Returns a total quantity of advised companies add-ons
  def advised_company_add_ons_quantity
    return 0 if not has_active_subscription?

    add_ons = subscription.add_ons
    return 0 if add_ons.empty?

    by_advised_company_add_on_code = lambda { |add_on| add_on['add_on_code'] == ADVISED_COMPANY_ADD_ON_CODE }
    advised_company_add_on = add_ons.find(&by_advised_company_add_on_code)
    advised_company_add_on['quantity']
  end

  private

  # Terminate an active subscription
  def terminate_subscription_for(company)
    subscriber = company.subscriber

    terminated = subscriber.terminate_subscription
    company.subscription.update_attribute(:terminated_by_advisor, true) if terminated

    terminated
  end

  def renew_terminated_subscription_for(company)
    subscriber = company.subscriber(true)
    return true if not subscriber.present?
    return true if not subscriber.subscription_was_terminated_by_advisor?

    renewed_subscription = subscriber.subscribe_to_plan(company_subscription.plan_code, account_code: subscriber.account_code)
    renewed = renewed_subscription.valid?
    company.subscription.update_attribute(:terminated_by_advisor, false) if renewed

    renewed
  end

  def update_advised_company_add_ons_quantity(quantity = 0)
    return false unless has_active_subscription?

    attributes = { timeframe: 'now' }
    if quantity > 0
      attributes[:subscription_add_ons] = [{ add_on_code: ADVISED_COMPANY_ADD_ON_CODE, quantity: quantity }]
    end

    subscription.update_attributes(attributes)
  end
end
