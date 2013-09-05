class Api::V1::PeriodsController < Api::BaseController

  # GET /api/v1/periods.json
  def index
    periods = Period.all
    respond_with periods
  end

end
