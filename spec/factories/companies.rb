FactoryGirl.define do
  factory :company do
    ignore do
      users []
    end

    sequence(:name) { |n| "Company name #{n}" }
    sequence(:subdomain) { |n| "company-name-#{n}" }

    address_1 'Address line 1'
    address_2 'Address line 2'
    postal_code '1234'

    sequence(:url) { |n| "http://company_#{n}.com" }

    # Used along with ignored #users attribute
    # This will create a affiliation with the company and given users
    after(:create) do |company, evaluator|
      users = evaluator.users
      users.each { |user| company.invite_user(user) }
    end

    trait :without_scenarios do
      after(:build) do |company|
        company.scenarios = []
      end
    end

    trait :with_country do
      after(:build) do |company|
        company.country = create(:country)
      end
    end

    trait :with_industry do
      after(:build) do |company|
        company.industry = create(:industry)
      end
    end

    trait :demo_available do
      demo_status 'available'
    end

    trait :demo_taken do
      demo_status 'taken'
    end
  end

  factory :advisor_company, class: AdvisorCompany, parent: :company
end
