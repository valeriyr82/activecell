FactoryGirl.define do
  factory :period do
    first_day { Time.now.beginning_of_month + rand(36).months }
  end
end
