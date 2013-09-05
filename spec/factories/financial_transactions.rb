FactoryGirl.define do
  factory :financial_transaction do
    period
    account
    amount_cents 1000_00
  end
end
