FactoryGirl.define do
  factory :user do
    ignore do
      companies []
    end

    sequence(:name) { |n| "Test user #{n}" }
    sequence(:email) { |n| "test.user#{n}@email.com" }

    password 'password'
    password_confirmation { password }

    email_notifications false

    # Used along with ignored #companies attribute
    # This will create a affiliation with the user and given companies
    after(:create) do |user, evaluator|
      companies = evaluator.companies
      companies.each { |company| company.invite_user(user) }
    end

    trait :with_email_notifications do
      email_notifications true
    end

    trait :without_email_notifications do
      email_notifications false
    end

    trait :with_demo_company do
      after(:create) do |user|
        if user.companies.blank?
          company = create(:company, :demo_available)
          company.invite_user(user)
        else
          user.companies.each { |company| company.update_attribute(:demo_status, 'available') }
        end
      end
    end
  end
end
