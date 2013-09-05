# Reflects affiliation between company and its advisors
class AdvisorCompanyAffiliation < CompanyAffiliation
  include Mongoid::Paranoia

  field :override_branding, type: Boolean, default: false
  field :override_billing, type: Boolean, default: false

  attr_accessible :advisor_company_id
  attr_accessible :override_branding
  attr_accessible :override_billing

  belongs_to :advisor_company, class_name: 'Company', inverse_of: :advisor_company_affiliations
  validates :advisor_company, presence: true,
                              uniqueness: { scope: :company_id }

  index({ company_id: 1, advisor_company_id: 1 }, { unique: true })

  # When an access was revoked this method will rollback branding for the given advisor
  after_update :rollback_branding!, if: :access_revoked?

  # Before destroy set all flags to false
  after_destroy :rollback_branding!
  after_destroy :rollback_billing!

  def as_json(options = {})
    super(only: [:id, :has_access, :override_branding, :override_billing, :_type]).tap do |json|
      json[:can_override_branding] = can_override_branding?
      json[:can_override_billing] = can_override_billing?

      json[:company] = company.as_json \
        only: [:id, :name, :subdomain],
        exclude_advised_companies: true

      json[:advisor_company] = advisor_company.as_json \
        only: [:id, :name],
        except: [:is_connected_to_intuit, :is_intuit_token_expired],
        exclude_advised_companies: true
    end
  end

  # Returns true if on the current affiliation override branding is possible
  def can_override_branding?
    advisor_company.can_override_branding_for?(company)
  end

  # Returns true if on the current affiliation override billing is possible
  def can_override_billing?
    advisor_company.can_override_billing_for?(company)
  end

  private

  def rollback_branding!
    set(:override_branding, false)
  end

  def rollback_billing!
    set(:override_billing, false)
  end

  def access_revoked?
    has_access_changed? and not has_access?
  end

end
