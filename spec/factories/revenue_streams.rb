FactoryGirl.define do
  factory :revenue_stream do
    sequence(:name) { |n| "Revenue Stream Name #{n}" }
  end
end
