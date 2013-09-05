module AdvisorCompany::AdvisorBranding
  extend ActiveSupport::Concern

  # Returns true if the current advisor company can override a branding for given company
  def can_override_branding_for?(company)
    already_overridden = company.advisor_company_affiliations.with_access.where(:advisor_company_id.ne => id, override_branding: true).exists?
    not already_overridden
  end

  # Overrides branding for the given company
  def override_branding_for(company)
    return false unless can_override_branding_for?(company)

    affiliation = advised_company_affiliations.with_access.where(company_id: company.id).first
    affiliation.update_attribute(:override_branding, true)
  end
end
