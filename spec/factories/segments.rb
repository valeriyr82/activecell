FactoryGirl.define do
  factory :segment do
    sequence(:name) { |n| "Segment #{n}" }
  end
end
