FactoryGirl.define do
  factory :intuit_company do
    sequence(:access_token) { |n| "access_token_#{n}" }
    sequence(:access_secret) { |n| "access_secret_#{n}" }
    sequence(:realm) { |n| "realm_#{n}" }
    provider 'QBO'
    connected_at { Time.now }

    trait :with_company do
      after(:build) do |intuit_company|
        intuit_company.company = build(:company)
      end
    end

    trait :with_expired_token do
      connected_at { 6.months.ago }
    end
  end
end
