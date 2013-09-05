FactoryGirl.define do
  factory :task do
    sequence(:text) { |n| "Task #{n}" }
    done false
    user
    company

    trait :incompleted do
      done false
    end

    trait :completed do
      done true
    end
  end
end
