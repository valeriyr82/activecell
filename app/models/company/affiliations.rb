# Encapsulates affiliations between users and companies
# #user_affiliations a collection of all company's affiliations (users + advisor companies)
# #advisor_company_affiliations a collection of advisor companies affiliations
# #advised_company_affiliations a collection of advised companies affiliations
module Company::Affiliations
  extend ActiveSupport::Concern

  included do
    has_many :company_affiliations, class_name: 'CompanyAffiliation'

    has_many :user_affiliations, class_name: 'UserAffiliation'

    # Advisor companies
    has_many :advisor_company_affiliations, class_name: 'AdvisorCompanyAffiliation',
             inverse_of: :company, dependent: :destroy
  end

  # Returns users belongs to the given company
  # Result also includes users from advisor companies
  def users
    company_ids = [self.id]
    company_ids += advisor_company_ids if advised?

    user_ids = UserAffiliation.where(:company_id.in => company_ids).with_access.only(:user_id).map(&:user_id)
    User.where(:id.in => user_ids).order_by(created_at: :asc)
  end

  # Returns the first company's user
  def first_user
    users.first
  end

  # Returns true if the company is advised by other company (advisor)
  def advised?
    advisor_company_affiliations.with_access.present?
  end

  # Returns a list of all advisor companies
  def advisor_companies
    Company.where(:id.in => advisor_company_ids)
  end

  private

  def advisor_company_ids
    advisor_company_affiliations.with_access.only(:advisor_company_id).map(&:advisor_company_id)
  end

end
