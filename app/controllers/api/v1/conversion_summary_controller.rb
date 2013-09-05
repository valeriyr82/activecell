class Api::V1::ConversionSummaryController < Api::ResourcesController
  actions :index

  def update
    filter_params! :customer_volume
    super
  end
end
