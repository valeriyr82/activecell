FactoryGirl.define do
  factory :company_affiliation, class: CompanyAffiliation do
    company
    has_access true

    trait :without_access do
      has_access false
    end
  end

  factory :company_advisor_affiliation, class: AdvisorCompanyAffiliation, parent: :company_affiliation do
    advisor_company { create(:advisor_company) }

    trait :branding_overridden do
      override_branding true
    end

    trait :billing_overridden do
      override_billing true
    end
  end
end
