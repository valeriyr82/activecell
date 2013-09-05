FactoryGirl.define do
  factory :document do
    sequence(:response) { |n| "{ JSON response as provided by the source system #{n} }" }
  end
end
