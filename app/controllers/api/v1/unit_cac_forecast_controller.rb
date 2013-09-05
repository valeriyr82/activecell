class Api::V1::UnitCacForecastController < Api::ResourcesController
  actions :index

  def update
    filter_params!
    super
  end
end
