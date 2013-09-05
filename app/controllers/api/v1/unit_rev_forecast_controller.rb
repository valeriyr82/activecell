class Api::V1::UnitRevForecastController < Api::ResourcesController
  actions :index

  def update
    filter_params!
    super
  end
end
