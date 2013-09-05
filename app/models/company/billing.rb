module Company::Billing
  extend ActiveSupport::Concern

  included do
    embeds_one :subscription, class_name: 'CompanySubscription'
  end

  def subscriber(skip_overridden_billing_check = false)
    return nil if not skip_overridden_billing_check and billing_overridden?
    @subscriber ||= RecurlySubscriber.new(self)
  end

  def billing_overridden?
    advisor_company_affiliation_which_overrides_billing.present?
  end

  # TODO refactor this
  def trial_expired?
    RecurlySubscriber.new(self).trial_expired?
  end

  private

  def advisor_company_affiliation_which_overrides_billing
    advisor_company_affiliations.with_access.where(override_billing: true).first
  end

end
