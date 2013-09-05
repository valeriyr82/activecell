# API endpoint used on company/settings page
class Api::V1::Company::AffiliationsController < Api::ResourcesController

  def index
    affiliations = current_company.company_affiliations
    respond_with(affiliations)
  end

  # Used for grant and revoke an access
  def update
    affiliations = current_company.company_affiliations.find(params[:id])
    affiliations.update_attributes(params[:company_affiliation])
    respond_with(affiliations)
  end

end
