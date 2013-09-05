class Api::V1::CompanyBrandingsController < Api::ResourcesController

  # PUT /api/v1/company_branding.json
  def update
    resource.update_attributes(params[:company_branding])
    respond_with(resource)
  end

  private

  def resource
    current_company.branding
  end

end
