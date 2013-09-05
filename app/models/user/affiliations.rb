# Encapsulates logic for an access to other companies
module User::Affiliations
  extend ActiveSupport::Concern

  included do
    has_many :company_affiliations, class_name: 'UserAffiliation',
             inverse_of: :user, dependent: :destroy
  end

  # Returns all user's companies
  def companies
    company_ids = company_affiliations.with_access.map(&:company_id)
    Company.where(:id.in => company_ids)
  end

  # Returns a list of user's advisor companies
  def advisor_companies
    companies.where(_type: AdvisorCompany)
  end

  # Returns companies to which the user has an access as an advisor
  def advised_companies
    Company.where(:id.in => advised_company_ids)
  end

  # Returns true if an user belongs to at least one advisor company
  def is_advisor?
    not advisor_companies.empty?
  end

  def first_company
    companies.first
  end

  # TODO replace with sth more fancy, for example: user.has_access_to(company)
  # Returns true if the user has an access to the given company's
  def has_subdomain?(subdomain)
    owned_subdomains.include?(subdomain)
  end

  def without_company?
    companies.empty?
  end

  private

  # Returns a list of subdomains owned by the user
  def owned_subdomains
    companies.map(&:subdomain) + advised_companies.map(&:subdomain)
  end

  def advised_company_ids
    ids = Set.new
    advisor_companies.each do |company|
      ids += company.advised_company_affiliations.with_access.map(&:company_id)
    end

    ids.to_a
  end

end
