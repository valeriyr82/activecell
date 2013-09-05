module AdvisorCompany::AdvisorBilling
  extend ActiveSupport::Concern

  def subscriber
    @subscriber ||= RecurlyAdvisorSubscriber.new(self)
  end

  # Returns true if the current advisor company can override a billing for given company
  def can_override_billing_for?(company)
    already_overridden = company.advisor_company_affiliations.with_access.where(:advisor_company_id.ne => id, override_billing: true).exists?
    not already_overridden
  end

  # Overrides billing for the given company
  # This will trigger AdvisorCompanyAffiliationObserver
  def override_billing_for(company)
    return false unless can_override_billing_for?(company)

    affiliation = advised_company_affiliations.with_access.where(company_id: company.id).first
    affiliation.update_attribute(:override_billing, true)
  end
end
