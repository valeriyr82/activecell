FactoryGirl.define do
  factory :conversion_summary do
    sequence(:customer_volume) { |n| n }
  end
end
