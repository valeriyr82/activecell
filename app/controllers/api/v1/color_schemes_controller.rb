class Api::V1::ColorSchemesController < Api::BaseController

  # GET /api/v1/color_scheme
  def show
    respond_with(color_scheme)
  end

  # POST /api/v1/color_scheme
  def create
    new_color_scheme = current_company.branding.create_color_scheme
    respond_with(color_scheme, location: api_v1_color_scheme_url(new_color_scheme))
  end

  # UPDATE /api/v1/color_scheme
  def update
    color_scheme.update_attributes(params[:color_scheme])
    respond_with(color_scheme)
  end

  # DELETE /api/v1/color_scheme
  def destroy
    color_scheme.destroy
    respond_with(color_scheme)
  end

  private

  def color_scheme
    @color_scheme ||= current_company.branding_color_scheme
  end

end
