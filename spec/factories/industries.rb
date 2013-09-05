FactoryGirl.define do
  factory :industry do
    sequence(:name) { |n| "Industry Name #{n}" }
  end
end
