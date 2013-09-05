class AdvisorCompany < Company
  include AdvisorCompany::AdvisorAffiliations
  include AdvisorCompany::AdvisorDowngrade
  include AdvisorCompany::AdvisorBranding
  include AdvisorCompany::AdvisorBilling

  def as_json(options = {})
    super(options).tap do |json|
      json[:advised_companies] = advised_company_affiliations.as_json if not options[:exclude_advised_companies]
    end
  end
end
