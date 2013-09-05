FactoryGirl.define do
  factory :vendor do
    sequence(:name) { |n| "Vendor #{n}" }
  end
end
