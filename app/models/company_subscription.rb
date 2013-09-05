class CompanySubscription
  include Api::BaseDocument
  include Mongoid::Timestamps

  # Unique subscription ID
  field :uuid, type: String
  # "active", "canceled", "future", "expired", "modified"
  field :state, type: String

  # Plan details
  field :plan_code, type: String
  field :plan_name, type: String

  # "days", or "months", defaults to "months"
  field :plan_interval_unit, type: String
  # Plan interval length, defaults to 1
  field :plan_interval_length, type: Integer
  field :plan_unit_amount_in_cents, type: Integer

  # Date the subscription will end (if state is "canceled"), ended (if state is "expired"), or was modified (if state is "modified")
  field :expires_at, type: Time
  # Date the trial ended, if applicable
  field :trial_ends_at, type: Time

  # This flag is set to true when the subscription is terminated by an advisor and it has to be
  # recreated when an advisor resign from override the billing
  field :terminated_by_advisor, type: Boolean, default: false

  embedded_in :company, inverse_of: :subscription
end
