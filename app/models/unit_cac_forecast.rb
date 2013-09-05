class UnitCacForecast
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::ForecastDocument

  field :unit_cac_forecast, type: Integer

  belongs_to :category
  belongs_to :channel
end
