FactoryGirl.define do
  factory :activity do
    sequence(:content) { |n| "Activity content #{n}" }
  end
end
