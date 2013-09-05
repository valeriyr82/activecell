FactoryGirl.define do
  factory :company_subscription do
    plan_code 'monthly'
    plan_name 'Activecell Monthly'

    trait :active do
      state 'active'
    end

    trait :canceled do
      state 'canceled'
      expires_at { 1.month.from_now }
    end
  end
end
