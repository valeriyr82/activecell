FactoryGirl.define do
  factory :background_job do
    company
  end

  trait :queued do
    status :queued
  end

  trait :working do
    status :working
  end

  trait :completed do
    status :completed
    completed_at { Time.now }
  end

  trait :failed do
    status :failed
    message 'Exception message'
  end
end
