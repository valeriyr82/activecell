# API endpoint used on company/advisor setting page
class Api::V1::Company::AdvisedCompanyAffiliationsController < Api::ResourcesController

  def index
    affiliation = current_company.advised_company_affiliations.with_access
    respond_with(affiliation)
  end

  def update
    affiliation = current_company.advised_company_affiliations.with_access.find(params[:id])
    affiliation.update_attributes(params[:company_affiliation])
    respond_with(affiliation)
  end

end
