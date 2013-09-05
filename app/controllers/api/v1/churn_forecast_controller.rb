class Api::V1::ChurnForecastController < Api::ResourcesController
  actions :index

  def update
    filter_params!
    super
  end
end
