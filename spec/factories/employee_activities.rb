FactoryGirl.define do
  factory :employee_activity do
    sequence(:name) { |n| "Employee Activity #{n}" }
  end
end
