class Api::V1::ConversionForecastController < Api::ResourcesController
  actions :index

  def update
    filter_params! :conversion_forecast
    super
  end
end
