module AdvisorCompany::AdvisorAffiliations
  extend ActiveSupport::Concern

  included do
    # Advised companies affiliations
    has_many :advised_company_affiliations, class_name: 'AdvisorCompanyAffiliation',
             inverse_of: :advisor_company, dependent: :destroy
  end

  # Returns a list of all advised companies
  # Raise an error when the company is not an advisor
  def advised_companies
    Company.where(:id.in => advised_company_ids)
  end

  # Invite other company as an advised company
  # It raises an exception when the company is not an advisor
  def become_an_advisor_for(company)
    advised_company_affiliations.create(company_id: company.id)
  end

  private

  def advised_company_ids
    advised_company_affiliations.with_access.map(&:company_id)
  end

end
