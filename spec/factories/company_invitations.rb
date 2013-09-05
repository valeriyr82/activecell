FactoryGirl.define do
  factory :company_invitation do
    company
    sequence(:email) { |n| "invited.user#{n}@email.com" }
  end
end
