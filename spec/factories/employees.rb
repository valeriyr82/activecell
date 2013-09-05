FactoryGirl.define do
  factory :employee do
    sequence(:name) { |n| "Employee #{n}" }
    employee_type
  end
end
