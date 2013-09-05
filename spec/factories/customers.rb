FactoryGirl.define do
  factory :customer do
    sequence(:name) { |n| "Customer #{n}" }
    channel
    segment
  end
end
