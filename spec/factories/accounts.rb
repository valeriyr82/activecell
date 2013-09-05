FactoryGirl.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }
    type 'Asset'
    sub_type 'Bank'
    account_number '72613'
    current_balance 10000000
    current_balance_currency 'USD'
    current_balance_as_of '2012-01-01'
    is_active true
  end
end
