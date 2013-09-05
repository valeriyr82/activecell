FactoryGirl.define do
  factory :expense_forecast do
    sequence(:name) { |n| "Expense Forecast #{n}" }
    category
    scenario
    occurrence 'Monthly'
    occurrence_month 12
    association :occurrence_period, factory: :period
    fixed_cost 15000
    percent_revenue 0.000125
  end
end
