FactoryGirl.define do
  factory :scenario do
    sequence(:name) { |n| "Scenario Name #{n}" }
  end
end
