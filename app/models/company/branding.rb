module Company::Branding
  extend ActiveSupport::Concern

  included do
    embeds_one :branding, class_name: 'CompanyBranding'
    after_initialize :build_branding, unless: lambda { |company| company.branding.present? }
    delegate :color_scheme, to: :branding, prefix: true

    alias_method_chain :branding, :advisor
  end

  # Returns true is branding is overridden by advisor.
  def branding_overridden?
    advisor_company_affiliation_which_overrides_branding.present?
  end

  # Returns company's branding.
  # If branding is overridden, returns advisor's branding.
  def branding_with_advisor
    if branding_overridden?
      advisor_company_affiliation_which_overrides_branding.advisor_company.branding
    else
      branding_without_advisor
    end
  end

  private

  def advisor_company_affiliation_which_overrides_branding
    advisor_company_affiliations.with_access.where(override_branding: true).first
  end

end
