FactoryGirl.define do
  factory :stage do
    sequence(:name) { |n| "Stage #{n}" }
    sequence(:position) { |n| n + 1 }
  end
end
