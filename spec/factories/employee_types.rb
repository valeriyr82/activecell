FactoryGirl.define do
  factory :employee_type do
    sequence(:name) { |n| "Employee type #{n}" }
  end
end
