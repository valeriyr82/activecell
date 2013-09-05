class ConversionForecast
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::ForecastDocument

  field :conversion_forecast, type: Integer

  belongs_to :period
  belongs_to :stage
  belongs_to :channel
end
